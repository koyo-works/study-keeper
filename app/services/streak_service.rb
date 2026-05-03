class StreakService
  def initialize(user, as_of: Date.current)
    @user  = user
    @as_of = as_of
  end

  def call
    recorded_dates = @user.records
                          .pluck(:logged_at)
                          .map { |t| t.in_time_zone("Tokyo").to_date }
                          .uniq
                          .to_set

    return 0 if recorded_dates.empty?

    # as_of日に記録があればそこから、なければ前日からカウント開始
    check_date = recorded_dates.include?(@as_of) ? @as_of : @as_of - 1

    return 0 unless recorded_dates.include?(check_date)

    streak = 0
    loop do
      break unless recorded_dates.include?(check_date)
      streak += 1
      check_date -= 1
    end

    streak
  end
end
