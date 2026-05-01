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

    # 日付をまたいだ直後も表示できるよう、今日の開始と6時間前の早い方を起点にする
    current_log_cutoff = [now.beginning_of_day, now - 6.hours].min
    current_log = current_user.records
                               .includes(:activity)
                               .where(ended_at: nil)
                               .where("logged_at >= ?", current_log_cutoff)
                               .order(logged_at: :desc)
                               .first

    render json: {
      logs: build_logs_json(logs),
      summary_per_category: summarize_per_activity(logs, now),
      current_log: current_log&.then { |l| build_record_json(l) },
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
      ended_at: record.ended_at&.in_time_zone("Tokyo")&.iso8601,  # ← 追加
      memo: record.memo
    }
  end

  def summarize_per_activity(logs, now)
    return [] if logs.empty?

    sums = Hash.new { |h, k| h[k] = { total_seconds: 0, count: 0, activity_name: nil } }

    logs.each_with_index do |log, i|
      # ended_atなし・次のログもない場合は進行中とみなし0秒（フロントのbuildLiveSummaryが加算）
      end_time = log.ended_at || logs[i + 1]&.logged_at || log.logged_at

      diff_seconds = [(end_time - log.logged_at).to_i, 0].max
      diff_seconds = [diff_seconds, 43200].min

      key = log.activity.public_id

      sums[key][:total_seconds] += diff_seconds
      sums[key][:count] += 1
      sums[key][:activity_name] ||= log.activity.name
    end

    sums.map do |activity_id, v|
      {
        activity_id: activity_id,
        activity_name: v[:activity_name],
        total_seconds: v[:total_seconds],
        count: v[:count]
      }
    end.sort_by { |h| -h[:total_seconds] }
  end
end