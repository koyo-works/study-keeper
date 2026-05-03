# frozen_string_literal: true

require "test_helper"

class Api::MonthlyControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user     = create(:user)
    @activity = create(:activity, user: @user)
  end

  # --- 認証 ---

  test "未ログインは401を返す" do
    get "/api/monthly", headers: { "Accept" => "application/json" }
    assert_response :unauthorized
  end

  # --- データなし ---

  test "記録なしでもエラーにならない" do
    sign_in @user
    get "/api/monthly"
    assert_response :success
    body = response.parsed_body
    assert_equal({}, body["daily_summaries"])
  end

  # --- 月の範囲 ---

  test "当月の開始・終了日が返る" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 15, 10, 0, 0) do
      get "/api/monthly"
      body = response.parsed_body
      assert_equal "2024-05-01", body["month_start"]
      assert_equal "2024-05-31", body["month_end"]
    end
  end

  test "monthパラメータで前月を表示できる" do
    sign_in @user
    get "/api/monthly", params: { month: "2024-04" }
    body = response.parsed_body
    assert_equal "2024-04-01", body["month_start"]
    assert_equal "2024-04-30", body["month_end"]
  end

  # --- 日別代表カテゴリ ---

  test "記録のある日にdaily_summariesが作られる" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 10, 10, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: Time.current - 1.hour, ended_at: Time.current)
      get "/api/monthly"
      body = response.parsed_body
      assert body["daily_summaries"].key?("2024-05-10")
    end
  end

  test "dominant_categoryは最も時間の多い行動名になる" do
    sign_in @user
    activity2 = create(:activity, user: @user)
    travel_to Time.zone.local(2024, 5, 10, 12, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: Time.current - 30.minutes, ended_at: Time.current)
      create(:record, user: @user, activity: activity2,
             logged_at: Time.current - 2.hours, ended_at: Time.current - 30.minutes)
      get "/api/monthly"
      dominant = response.parsed_body["daily_summaries"]["2024-05-10"]["dominant_category"]
      assert_equal activity2.name, dominant
    end
  end

  test "記録のない日はdaily_summariesに含まれない" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 10, 10, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: Time.current - 1.hour, ended_at: Time.current)
      get "/api/monthly"
      body = response.parsed_body
      assert_not body["daily_summaries"].key?("2024-05-09")
    end
  end

  test "先月の記録は当月のdaily_summariesに含まれない" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 10, 10, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: Time.zone.local(2024, 4, 30, 9, 0), ended_at: Time.zone.local(2024, 4, 30, 10, 0))
      get "/api/monthly"
      assert_equal({}, response.parsed_body["daily_summaries"])
    end
  end

  test "daily_summariesにtotal_secondsが含まれる" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 10, 10, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: Time.current - 1.hour, ended_at: Time.current)
      get "/api/monthly"
      day = response.parsed_body["daily_summaries"]["2024-05-10"]
      assert day.key?("total_seconds")
      assert_equal 3600, day["total_seconds"]
    end
  end
end
