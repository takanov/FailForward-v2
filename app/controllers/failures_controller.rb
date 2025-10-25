class FailuresController < ApplicationController
  before_action :authenticate_user!
  before_action :set_failure, only: [ :show, :edit, :update, :destroy, :complete ]

  def index
    @failures = Failure.all

    # 検索機能
    if params[:search].present?
      @failures = @failures.where("content LIKE ?", "%#{params[:search]}%")
    end

    # フィルター機能
    case params[:filter]
    when "completed"
      @failures = @failures.completed
    when "pending"
      @failures = @failures.pending
    when "overdue"
      @failures = @failures.overdue
    end

    # ソート機能
    case params[:sort]
    when "priority"
      @failures = @failures.by_priority
    when "due_date"
      @failures = @failures.by_due_date
    else
      @failures = @failures.order(created_at: :desc)
    end

    # 統計情報の計算
    @stats = {
      total: Failure.count,
      completed: Failure.completed.count,
      pending: Failure.pending.count,
      overdue: Failure.overdue.count
    }
  end

  def show
  end

  def new
    @failure = Failure.new
    @failure.due_date = 1.day.from_now
    @failure.priority = 2
  end

  def create
    @failure = current_user.failures.build(failure_params)
    if @failure.save
      redirect_to failures_path, notice: "投稿が完了しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @failure.update(failure_params)
      redirect_to @failure, notice: "投稿が更新されました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @failure.destroy
    redirect_to failures_path, notice: "投稿が削除されました。"
  end

  def complete
    @failure.update(resolved: !@failure.resolved)
    redirect_to failures_path, notice: "投稿を#{@failure.resolved? ? "完了" : "未完了"}にしました。"
  end

  private

  def set_failure
    @failure = Failure.find(params[:id])
  end

  def failure_params
    params.require(:failure).permit(:content, :tags, :priority, :due_date, :resolved)
  end
end
