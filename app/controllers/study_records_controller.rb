class StudyRecordsController < ApplicationController
  before_action :authenticate_user!
  def new
    @activities = Activity.all
    @record = Record.new
  end

  def create
    @record = current_user.records.new(record_params)
    @record.logged_at ||= Time.current

    if @record.save
      redirect_to learning_path, notice: "記録しました"
    else
      @activities = Activity.all
      flash.now[:alert] = "行動を選択してください"
      render :new, status: :unprocessable_entity
    end
  end

  private
  
  def record_params
    params.require(:record).permit(:activity_id, :memo)
  end
end
