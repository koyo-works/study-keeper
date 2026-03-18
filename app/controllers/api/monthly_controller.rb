class Api::MonthlyController < ApplicationController
  before_action :authenticate_user!

  def index
    base_date = params[:month].present? ? Date.parse("#{params[:month]}-01") : Date.current
    month_start = base_date.beginning_of_month
    month_end = base_date.end_of_month

    logs = current_user.records.where(logged_at: month_start.beginning_of_day..month_end.end_of_day).includes(:activity)

    daily_summaries = {}
    logs.group_by { |log| log.logged_at.to_date }.each do |date, day_logs|
      summary = WeeklySummaryService.new(day_logs).call
      next if summary.empty?
      daily_summaries[date.iso8601] = {
        dominant_category: summary.first[:activity_name],
        total_minutes: summary.sum { |s| s[:total_minutes]},
        per_category: summary
      }
    end

    render json: {
      month_start: month_start.iso8601,
      month_end: month_end.iso8601,
      daily_summaries: daily_summaries
    }
  end
end