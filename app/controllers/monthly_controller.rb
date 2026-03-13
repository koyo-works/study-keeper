class MonthlyController < ApplicationController
  before_action :authenticate_user!

  def index
    base_date = params[:month].present? ? Date.parse("#{params[:month]}-01") : Date.current
    @month_start = base_date.beginning_of_month
    @month_end = base_date.end_of_month
    @monthly_logs = current_user.records.where(logged_at: @month_start.beginning_of_day..@month_end.end_of_day).includes(:activity)
  
    @daily_summaries = {}
    @monthly_logs.group_by { |log| log.logged_at.to_date }.each do |date, logs|
      summary = WeeklySummaryService.new(logs).call
      next if summary.empty?
      dominant = summary.first
      @daily_summaries[date] = {
        dominant_category: dominant[:activity_name],
        total_minutes: summary.sum { |s| s[:total_minutes] },
        per_category: summary
      }
    end
  end
end