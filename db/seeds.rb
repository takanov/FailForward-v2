# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# 既存のデータをクリア（開発環境のみ）
if Rails.env.development?
  puts "既存のデータを削除中..."
  Failure.destroy_all
  User.destroy_all
end

# ユーザーの作成
puts "ユーザーを作成中..."
users = []

users << User.create!(
  name: "山田太郎",
  email: "yamada@example.com",
  password: "password123",
  password_confirmation: "password123"
)

users << User.create!(
  name: "佐藤花子",
  email: "sato@example.com",
  password: "password123",
  password_confirmation: "password123"
)

users << User.create!(
  name: "田中一郎",
  email: "tanaka@example.com",
  password: "password123",
  password_confirmation: "password123"
)

puts "#{users.count}人のユーザーを作成しました"

# 失敗データの作成
puts "失敗データを作成中..."

failure_contents = [
  { content: "プレゼンテーションで資料の順番を間違えて、話の流れがおかしくなってしまった", tags: "仕事, プレゼン", priority: 1 },
  { content: "重要な会議の時間を1時間勘違いして遅刻してしまった", tags: "仕事, スケジュール管理", priority: 1 },
  { content: "プログラムのバグを見逃して本番環境にデプロイしてしまった", tags: "プログラミング, レビュー", priority: 1 },
  { content: "クライアントへのメールで相手の名前を間違えて送信してしまった", tags: "コミュニケーション, メール", priority: 2 },
  { content: "締め切りを勘違いしていて、タスクを完了できなかった", tags: "仕事, タスク管理", priority: 2 },
  { content: "チーム会議で発言するタイミングを逃してしまった", tags: "コミュニケーション, 会議", priority: 3 },
  { content: "ドキュメントの更新を忘れて、チームメンバーに混乱を招いた", tags: "ドキュメント, チームワーク", priority: 2 },
  { content: "コードレビューでの指摘を見落として、同じミスを繰り返した", tags: "プログラミング, レビュー", priority: 2 },
  { content: "新しいツールの使い方を理解せずに作業を始めて時間を無駄にした", tags: "ツール, 学習", priority: 3 },
  { content: "テストケースを十分に作成せず、後でバグが見つかった", tags: "プログラミング, テスト", priority: 1 },
  { content: "顧客との約束を手帳に書き忘れて、すっぽかしてしまった", tags: "スケジュール管理, 顧客対応", priority: 1 },
  { content: "データベースのバックアップを取らずに大規模な変更を実施した", tags: "データベース, リスク管理", priority: 1 },
  { content: "チームメンバーへの感謝の言葉を伝え忘れて、モチベーションを下げてしまった", tags: "チームワーク, コミュニケーション", priority: 3 },
  { content: "プロジェクトの見積もりを甘く設定して、納期に間に合わなかった", tags: "プロジェクト管理, 見積もり", priority: 2 },
  { content: "重要な資料をバージョン管理せず、古いバージョンを使ってしまった", tags: "バージョン管理, ドキュメント", priority: 2 },
]

failures_created = 0

failure_contents.each_with_index do |failure_data, index|
  user = users.sample

  # ランダムな期限を設定（過去、現在、未来）
  due_date = case index % 4
  when 0
    2.days.ago # 期限切れ
  when 1
    2.days.from_now # 近い将来
  when 2
    7.days.from_now # 1週間後
  else
    14.days.from_now # 2週間後
  end

  # ランダムに解決済みにする
  resolved = [ true, false, false, false ].sample

  Failure.create!(
    user: user,
    content: failure_data[:content],
    tags: failure_data[:tags],
    priority: failure_data[:priority],
    due_date: due_date,
    resolved: resolved
  )

  failures_created += 1
end

puts "#{failures_created}件の失敗データを作成しました"

# 統計を表示
puts "\n=== シードデータ作成完了 ==="
puts "総ユーザー数: #{User.count}"
puts "総失敗数: #{Failure.count}"
puts "完了済み: #{Failure.completed.count}"
puts "進行中: #{Failure.pending.count}"
puts "期限切れ: #{Failure.overdue.count}"
puts "\nログイン情報:"
puts "  Email: yamada@example.com"
puts "  Password: password123"
