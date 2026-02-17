class Api::DashboardController < ApplicationController
  before_action :authenticate_user!

  def today
    now = Time.current
    start_at = now.beginning_of_day
    end_at   = now.end_of_day

    logs = current_user.records
                       .includes(:activity)
                       .where(logged_at: start_at..end_at)
                       .order(:logged_at)

    render json: {
      logs: build_logs_json(logs),
      summary_per_category: summarize_per_activity(logs, now),
      current_log: logs.last ? build_record_json(logs.last) : nil,
      now: now.iso8601
    }
  end

  private

  def build_logs_json(logs)
    logs.map { |r| build_record_json(r) }
  end

  def build_record_json(record)
    {
      id: record.public_id,
      activity: {
        id: record.activity.public_id,
        name: record.activity.name
      },
      logged_at: record.logged_at.in_time_zone("Tokyo").iso8601,
      memo: record.memo
    }
  end

  def summarize_per_activity(logs, now)
    return [] if logs.empty?

    sums = Hash.new { |h, k| h[k] = { total_minutes: 0, count: 0, activity_name: nil } }

    logs.each_with_index do |log, i|
      next_time = logs[i + 1]&.logged_at || now

      diff_minutes = ((next_time - log.logged_at) / 60).floor
      diff_minutes = 0 if diff_minutes.negative?
      diff_minutes = [diff_minutes, 360].min

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