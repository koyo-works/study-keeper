# frozen_string_literal: true

require "test_helper"

class WeeklySummaryServiceTest < ActiveSupport::TestCase
  setup do
    @user     = create(:user)
    @activity = create(:activity, user: @user)
  end

  test "記録なしは空配列を返す" do
    result = WeeklySummaryService.new([]).call
    assert_equal [], result
  end

  test "ended_atから時間を計算する" do
    logs = [
      create(:record, user: @user, activity: @activity,
             logged_at: Time.zone.local(2024, 5, 1, 9, 0), ended_at: Time.zone.local(2024, 5, 1, 10, 0))
    ]
    result = WeeklySummaryService.new(logs).call
    assert_equal 3600, result.first[:total_seconds]
  end

  test "ended_atを次のlogged_atより優先する" do
    activity2 = create(:activity, user: @user)
    t1 = Time.zone.local(2024, 5, 1, 9, 0)
    # ended_at = 30分後、次のログ = 50分後 → ended_atを使うべき
    log1 = create(:record, user: @user, activity: @activity,
                  logged_at: t1, ended_at: t1 + 30.minutes)
    log2 = create(:record, user: @user, activity: activity2,
                  logged_at: t1 + 50.minutes, ended_at: t1 + 60.minutes)
    result = WeeklySummaryService.new([log1, log2]).call
    entry = result.find { |s| s[:activity_id] == @activity.public_id }
    assert_equal 1800, entry[:total_seconds]
  end

  test "ended_atなし・同日の次ログありは次のlogged_atで計算する" do
    activity2 = create(:activity, user: @user)
    t1 = Time.zone.local(2024, 5, 1, 9, 0)
    log1 = create(:record, user: @user, activity: @activity,
                  logged_at: t1, ended_at: nil)
    log2 = create(:record, user: @user, activity: activity2,
                  logged_at: t1 + 45.minutes, ended_at: t1 + 60.minutes)
    result = WeeklySummaryService.new([log1, log2]).call
    entry = result.find { |s| s[:activity_id] == @activity.public_id }
    assert_equal 2700, entry[:total_seconds]
  end

  test "ended_atなし・次ログなしはカウントしない" do
    logs = [
      create(:record, user: @user, activity: @activity,
             logged_at: Time.zone.local(2024, 5, 1, 9, 0), ended_at: nil)
    ]
    result = WeeklySummaryService.new(logs).call
    assert_equal [], result
  end

  test "ended_atなし・次ログが翌日はカウントしない" do
    activity2 = create(:activity, user: @user)
    log1 = create(:record, user: @user, activity: @activity,
                  logged_at: Time.zone.local(2024, 5, 1, 23, 0), ended_at: nil)
    log2 = create(:record, user: @user, activity: activity2,
                  logged_at: Time.zone.local(2024, 5, 2, 1, 0), ended_at: Time.zone.local(2024, 5, 2, 2, 0))
    result = WeeklySummaryService.new([log1, log2]).call
    entry = result.find { |s| s[:activity_id] == @activity.public_id }
    assert_nil entry
  end

  test "43200秒(12時間)を超える場合は43200秒に丸める" do
    logs = [
      create(:record, user: @user, activity: @activity,
             logged_at: Time.zone.local(2024, 5, 1, 0, 0), ended_at: Time.zone.local(2024, 5, 1, 14, 0))
    ]
    result = WeeklySummaryService.new(logs).call
    assert_equal 43200, result.first[:total_seconds]
  end

  test "同じ行動の複数ログは合算される" do
    t = Time.zone.local(2024, 5, 1, 9, 0)
    create(:record, user: @user, activity: @activity,
           logged_at: t, ended_at: t + 30.minutes)
    create(:record, user: @user, activity: @activity,
           logged_at: t + 2.hours, ended_at: t + 2.hours + 30.minutes)
    result = WeeklySummaryService.new(@user.records.includes(:activity).to_a).call
    assert_equal 3600, result.first[:total_seconds]
    assert_equal 2,    result.first[:count]
  end

  test "割合が合計に対して正しく計算される" do
    activity2 = create(:activity, user: @user)
    t = Time.zone.local(2024, 5, 1, 9, 0)
    create(:record, user: @user, activity: @activity,
           logged_at: t, ended_at: t + 60.minutes)
    create(:record, user: @user, activity: activity2,
           logged_at: t + 60.minutes, ended_at: t + 120.minutes)
    result = WeeklySummaryService.new(@user.records.includes(:activity).to_a).call
    assert_equal 50, result.find { |s| s[:activity_id] == @activity.public_id }[:percentage]
    assert_equal 50, result.find { |s| s[:activity_id] == activity2.public_id }[:percentage]
  end

  test "合計時間の多い順にソートされる" do
    activity2 = create(:activity, user: @user)
    t = Time.zone.local(2024, 5, 1, 9, 0)
    create(:record, user: @user, activity: @activity,
           logged_at: t, ended_at: t + 30.minutes)
    create(:record, user: @user, activity: activity2,
           logged_at: t + 30.minutes, ended_at: t + 90.minutes)
    result = WeeklySummaryService.new(@user.records.includes(:activity).to_a).call
    assert_equal activity2.public_id, result.first[:activity_id]
  end
end
