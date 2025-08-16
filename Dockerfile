# syntax=docker/dockerfile:1
# check=error=true

# --- common base (runtime) ---
ARG RUBY_VERSION=3.3.0
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# minimal runtime deps (必要に応じて libpq5 を追加)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl libjemalloc2 libvips sqlite3 \
      libpq5 \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# --- build stage ---
FROM base AS build

# build-time deps（ネイティブ拡張に必要なものを追加）
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git libyaml-dev pkg-config \
      libpq-dev libsqlite3-dev libssl-dev zlib1g-dev \
      libxml2-dev libxslt1-dev imagemagick \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# lock に合わせて Bundler をピン止め
# （Gemfile.lock の末尾 "BUNDLED WITH" のバージョンを抽出）
ENV BUNDLE_FORCE_RUBY_PLATFORM=1
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v "$(awk '/^BUNDLED WITH$/{getline; gsub(/^ +/,""); print}' Gemfile.lock)"

# 依存解決（詳細ログで失敗gemを可視化したい場合は --verbose を付ける）
RUN bundle install --jobs 4 --retry 3

# --- base (runtime) は凍結のままでOK ---
ENV RAILS_ENV="production" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_FROZEN="1"

# --- build stage ---
FROM base AS build

# ここはそのまま（OSパッケージ追加はあなたの内容でOK）

# ← この直後に「凍結OFF」を上書き（重要）
ENV BUNDLE_DEPLOYMENT="" \
    BUNDLE_FROZEN="" \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_FORCE_RUBY_PLATFORM="1"

# 依存レイヤ
COPY Gemfile Gemfile.lock ./

# Bundler を lock に合わせてピン止め
RUN gem install bundler -v "$(awk '/^BUNDLED WITH$/{getline; gsub(/^ +/,""); print}' Gemfile.lock)"

# （デバッグ兼ねて）本当に一致を見る
RUN ruby -v && bundler -v && \
    echo "BUNDLED WITH:" && awk '/^BUNDLED WITH$/{getline; gsub(/^ +/,""); print}' Gemfile.lock && \
    echo "Check gem keyword (pagyなど):" && (grep -n "pagy\|kaminari\|page" Gemfile Gemfile.lock || true)

# ★ 凍結OFFで install（もしくは --no-deployment を付ける）
RUN bundle install --jobs 4 --retry 3
# 代替: RUN bundle install --no-deployment --jobs 4 --retry 3



# アプリ本体をコピー
COPY . .

# （任意）bundlerキャッシュ掃除
RUN rm -rf ~/.bundle "$BUNDLE_PATH"/ruby/*/cache "$BUNDLE_PATH"/ruby/*/bundler/gems/*/.git

# bootsnap は一旦オフ。ビルドが安定後に下を有効化
# RUN bundle exec bootsnap precompile --gemfile

# --- final image ---
FROM base

# gems とアプリを build から持ってくる
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# 非rootで実行
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]