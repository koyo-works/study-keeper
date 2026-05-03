class WeeklySummaryService
  MAX_SECONDS = 43200

  def initialize(logs)
    @logs = logs.sort_by(&:logged_at)
  end

  def call
    return [] if @logs.empty?

    sums = Hash.new { |h, k| h[k] = { total_seconds: 0, count: 0, activity_name: nil, activity_id: nil } }

    @logs.each_with_index do |log, i|
      next_log = @logs[i + 1]

      diff_seconds = if log.ended_at
                       (log.ended_at - log.logged_at).to_i
                     elsif next_log && next_log.logged_at.to_date == log.logged_at.to_date
                       (next_log.logged_at - log.logged_at).to_i
                     else
                       next
                     end

      diff_seconds = [[diff_seconds, 0].max, MAX_SECONDS].min

      key = log.activity.public_id
      sums[key][:total_seconds] += diff_seconds
      sums[key][:count]         += 1
      sums[key][:activity_name] ||= log.activity.name
      sums[key][:activity_id]   ||= log.activity.public_id
      sums[key][:db_id]         ||= log.activity.id
      sums[key][:icon]          ||= log.activity.icon
    end

    total = sums.values.sum { |v| v[:total_seconds] }

    sums.map do |_, v|
      percentage = total > 0 ? (v[:total_seconds].to_f / total * 100).round : 0
      v.merge(percentage: percentage)
    end.sort_by { |h| -h[:total_seconds] }
  end
end
