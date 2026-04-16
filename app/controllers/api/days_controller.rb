class Api::DaysController < ApplicationController
  before_action :authenticate_user!

  def show
    date = Date.parse(params[:date])
    logs = current_user.records
                       .where(logged_at: date.beginning_of_day..date.end_of_day)
                       .includes(:activity)

    summary = WeeklySummaryService.new(logs).call

    share_link = ShareLink.find_or_create_by(
      user: current_user,
      share_type: :daily,
      target_date: date
    )

    render json: {
      date: date.iso8601,
      total_minutes: summary.sum { |s| s[:total_minutes] },
      per_category: summary.map { |s| { name: s[:activity_name], minutes: s[:total_minutes], ratio: s[:percentage] } },
      logs: logs.map { |log| { activity_name: log.activity.name, logged_at: log.logged_at, ended_at: log.ended_at } },
      share_token: share_link.token
    }
  rescue ArgumentError
    render json: { error: "不正な日付です" }, status: :bad_request
  end
end