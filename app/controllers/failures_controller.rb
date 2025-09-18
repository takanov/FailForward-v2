class FailuresController < ApplicationController
  def index
    @failures = Failure.all.order(created_at: :desc)
  end

  def show
  end

  def new
    @failure = Failure.new
  end

  def create
    @failure = current_user.failures.build(failure_params)
    if @failure.save
      redirect_to failures_path, notice: '投稿が完了しました。'
    else
      render :new
    end
  end
  def edit
    @failure = Failure.find(params[:id])
  end

  def update
    @failure = Failure.find(params[:id])
    if @failure.update(failure_params)
      redirect_to @failure, notice: '投稿が更新されました。'
    else
      render :edit
    end
  end

  def destroy
    @failure = Failure.find(params[:id])
    @failure.destroy
    redirect_to failures_path, notice: '投稿が削除されました。'
  end

  def failure_params
    params.require(:failure).permit(:content, :tags)
  end
end
