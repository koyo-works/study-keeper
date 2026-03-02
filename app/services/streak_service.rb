class StreakService
  def initialize(user)
    @user = user
  end

  def call
    recorded_dates = @user.records
                          .pluck(:logged_at)
                          .map { |t| t.in_time_zone("Tokyo").to_date }
                          .uniq
                          .to_set

    return 0 if recorded_dates.empty?

    # 今日記録があれば今日から、なければ昨日からカウント開始
    check_date = recorded_dates.include?(Date.current) ? Date.current : Date.current - 1

    # 昨日も記録がなければストリーク0
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
