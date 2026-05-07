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
      total_seconds: summary.sum { |s| s[:total_seconds] },
      per_category: summary.map { |s| { activity_id: s[:activity_id], name: s[:activity_name], seconds: s[:total_seconds], ratio: s[:percentage], icon: s[:icon] } },
      logs: logs.order(:logged_at).map { |log| { activity_id: log.activity.public_id, activity_name: log.activity.name, icon: log.activity.icon, logged_at: log.logged_at, ended_at: log.ended_at } },
      share_token: share_link.token
    }
  rescue ArgumentError
    render json: { error: "不正な日付です" }, status: :bad_request
  end
end