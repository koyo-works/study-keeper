class WeeklyController < ApplicationController
  before_action :authenticate_user!

  def index
    base_date = params[:week].present? ? Date.parse(params[:week]) : Date.current
    @week_start = base_date.beginning_of_week(:monday)
    @week_end   = base_date.end_of_week(:monday)
    @logs = current_user.records.in_week(base_date).includes(:activity)
    Rails.logger.debug "Weekly logs count: #{@logs.count} (#{@week_start} - #{@week_end})"
  end
end
