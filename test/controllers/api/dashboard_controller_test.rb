# frozen_string_literal: true

require "test_helper"

class Api::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user     = create(:user)
    @activity = create(:activity, user: @user)
  end

  # --- 認証 ---

  test "未ログインは401を返す" do
    get "/api/dashboard/today", headers: { "Accept" => "application/json" }
    assert_response :unauthorized
  end

  # --- データなし ---

  test "記録がなくてもエラーにならない" do
    sign_in @user
    get "/api/dashboard/today"
    assert_response :success
    body = response.parsed_body
    assert_equal [], body["logs"]
    assert_equal [], body["summary_per_category"]
    assert_nil body["current_log"]
  end

  # --- 今日の履歴 ---

  test "今日の記録が返る" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: 1.hour.ago, ended_at: Time.current)
      get "/api/dashboard/today"
      assert_response :success
      assert_equal 1, response.parsed_body["logs"].length
    end
  end

  test "昨日の記録はlogsに含まれない" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: 1.day.ago, ended_at: 1.day.ago + 30.minutes)
      get "/api/dashboard/today"
      assert_equal [], response.parsed_body["logs"]
    end
  end

  # --- current_log ---

  test "ended_atなしの記録はcurrent_logになる" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
      record = create(:record, user: @user, activity: @activity,
                      logged_at: 30.minutes.ago, ended_at: nil)
      get "/api/dashboard/today"
      body = response.parsed_body
      assert_not_nil body["current_log"]
      assert_equal record.public_id.to_s, body["current_log"]["id"]
    end
  end

  test "ended_atありの記録はcurrent_logにならない" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: 1.hour.ago, ended_at: Time.current)
      get "/api/dashboard/today"
      assert_nil response.parsed_body["current_log"]
    end
  end

  # --- サマリーロジック ---

  test "ended_atから経過時間を計算する" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: 30.minutes.ago, ended_at: Time.current)
      get "/api/dashboard/today"
      summary = response.parsed_body["summary_per_category"].first
      assert_equal 1800, summary["total_seconds"]
    end
  end

  test "ended_atなし・次のログありは次のlogged_atで計算する" do
    sign_in @user
    activity2 = create(:activity, user: @user)
    travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
      t1 = 50.minutes.ago
      t2 = t1 + 30.minutes
      create(:record, user: @user, activity: @activity,
             logged_at: t1, ended_at: nil)
      create(:record, user: @user, activity: activity2,
             logged_at: t2, ended_at: t2 + 10.minutes)
      get "/api/dashboard/today"
      summary = response.parsed_body["summary_per_category"]
                        .find { |s| s["activity_id"] == @activity.public_id.to_s }
      assert_equal 1800, summary["total_seconds"]
    end
  end

  test "計測中(ended_atなし・次のログなし)のサマリーは0秒" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: 30.minutes.ago, ended_at: nil)
      get "/api/dashboard/today"
      summary = response.parsed_body["summary_per_category"].first
      assert_equal 0, summary["total_seconds"]
    end
  end

  test "43200秒(12時間)を超える場合は43200秒に丸める" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 1, 23, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: Time.current.beginning_of_day, ended_at: Time.current)
      get "/api/dashboard/today"
      summary = response.parsed_body["summary_per_category"].first
      assert_equal 43200, summary["total_seconds"]
    end
  end

  # --- 日付境界 ---

  test "前日23:30開始のログはlogsに含まれないがcurrent_logになる" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 2, 0, 30, 0) do
      record = create(:record, user: @user, activity: @activity,
                      logged_at: Time.zone.local(2024, 5, 1, 23, 30, 0), ended_at: nil)
      get "/api/dashboard/today"
      body = response.parsed_body
      assert_equal [], body["logs"]
      assert_not_nil body["current_log"]
      assert_equal record.public_id.to_s, body["current_log"]["id"]
    end
  end

  test "深夜帯に6時間以上前(前日)のログはcurrent_logにならない" do
    sign_in @user
    # 2:00 AM のとき cutoff = min(00:00, 20:00前日) = 前日20:00
    # logged_at = 前日19:00 → cutoff より古いため current_log にならない
    travel_to Time.zone.local(2024, 5, 2, 2, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: 7.hours.ago, ended_at: nil)
      get "/api/dashboard/today"
      assert_nil response.parsed_body["current_log"]
    end
  end
end
