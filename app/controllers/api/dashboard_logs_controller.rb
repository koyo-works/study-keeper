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
      now = Time.current
      logs = current_user.records
                         .includes(:activity)
                         .where(logged_at: now.beginning_of_day..now.end_of_day)
                         .order(:logged_at)
      render json: {
        ok: true,
        record: build_record_json(record, activity),
        summary_per_category: summarize_per_activity(logs, now),
        now: now.iso8601
      }, status: :created
    else
      render json: {
        ok: false,
        error: record.errors.full_messages.first || "保存に失敗しました"
      }, status: :unprocessable_entity
    end
  end

  private

  def build_record_json(record, activity)
    {
      id: record.public_id,
      activity: {
        id: activity.public_id,
        name: activity.name
      },
      logged_at: record.logged_at.in_time_zone("Tokyo").iso8601,
      ended_at: record.ended_at&.in_time_zone("Tokyo")&.iso8601,  # ← 追加
      memo: record.memo
    }
  end

  def summarize_per_activity(logs, now)
    return [] if logs.empty?
    sums = Hash.new { |h, k| h[k] = { total_minutes: 0, count: 0, activity_name: nil } }
    logs.each_with_index do |log, i|
      next_time = logs[i + 1]&.logged_at || now
      diff_minutes = [[((next_time - log.logged_at) / 60).floor, 0].max, 360].min
      key = log.activity.public_id
      sums[key][:total_minutes] += diff_minutes
      sums[key][:count] += 1
      sums[key][:activity_name] ||= log.activity.name
    end
    sums.map do |activity_id, v|
      {
        activity_id: activity_id,
        activity_name: v[:activity_name],
        total_minutes: v[:total_minutes],
        count: v[:count]
      }
    end.sort_by { |h| -h[:total_minutes] }
  end
end