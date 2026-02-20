class Api::DashboardLogsController < ApplicationController
  before_action :authenticate_user!

  def create
    activity = Activity.find_by!(public_id: params[:activity_id])

    record = current_user.records.new(
      activity:  activity,
      memo:      params[:memo],
      logged_at: Time.zone.now
    )

    if record.save
      render json: {
        ok: true,
        record: {
          id: record.public_id,
          activity: {
            id: activity.public_id,
            name: activity.name
          },
          logged_at: record.logged_at.in_time_zone("Tokyo").iso8601,
          memo: record.memo
        }
      }, status: :created
    else
      render json: {
        ok: false,
        error: record.errors.full_messages.first || "保存に失敗しました"
      }, status: :unprocessable_entity
    end
  end
end