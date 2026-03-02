class Api::WeeklyController < ApplicationController
  before_action :authenticate_user!

  def index
    base_date  = params[:week].present? ? Date.parse(params[:week]) : Date.current
    week_start = base_date.beginning_of_week(:monday)
    week_end   = base_date.end_of_week(:monday)

    logs    = current_user.records.in_week(base_date).includes(:activity).order(:logged_at)
    summary = WeeklySummaryService.new(logs).call
    streak  = StreakService.new(current_user).call

    total_minutes = summary.sum { |s| s[:total_minutes] }

    render json: {
      week_start:    week_start.iso8601,
      week_end:      week_end.iso8601,
      total_minutes: total_minutes,
      summary:       summary,
      streak_days:   streak
    }
  end
end
