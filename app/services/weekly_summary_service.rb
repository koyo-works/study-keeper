class WeeklySummaryService
  MAX_MINUTES = 360

  def initialize(logs)
    @logs = logs.sort_by(&:logged_at)
  end

  def call
    return [] if @logs.empty?

    sums = Hash.new { |h, k| h[k] = { total_minutes: 0, count: 0, activity_name: nil, activity_id: nil } }

    @logs.each_with_index do |log, i|
      next_log = @logs[i + 1]

      diff_minutes = if next_log && next_log.logged_at.to_date == log.logged_at.to_date
                       ((next_log.logged_at - log.logged_at) / 60).floor
                     elsif log.ended_at
                       ((log.ended_at - log.logged_at) / 60).floor
                     else
                       next
                     end

      diff_minutes = [[diff_minutes, 0].max, MAX_MINUTES].min

      key = log.activity.public_id
      sums[key][:total_minutes] += diff_minutes
      sums[key][:count]         += 1
      sums[key][:activity_name] ||= log.activity.name
      sums[key][:activity_id]   ||= log.activity.public_id
    end

    total = sums.values.sum { |v| v[:total_minutes] }

    sums.map do |_, v|
      percentage = total > 0 ? (v[:total_minutes].to_f / total * 100).round : 0
      v.merge(percentage: percentage)
    end.sort_by { |h| -h[:total_minutes] }
  end
end
