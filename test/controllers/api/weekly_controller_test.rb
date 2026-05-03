# frozen_string_literal: true

require "test_helper"

class Api::WeeklyControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user     = create(:user)
    @activity = create(:activity, user: @user)
  end

  # --- 認証 ---

  test "未ログインは401を返す" do
    get "/api/weekly", headers: { "Accept" => "application/json" }
    assert_response :unauthorized
  end

  # --- データなし ---

  test "記録なしでもエラーにならない" do
    sign_in @user
    get "/api/weekly"
    assert_response :success
    body = response.parsed_body
    assert_equal [], body["summary"]
    assert_equal 0,  body["total_seconds"]
  end

  # --- 今週の集計 ---

  test "今週の記録が集計される" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: Time.current - 1.hour, ended_at: Time.current)
      get "/api/weekly"
      body = response.parsed_body
      assert_equal 3600, body["total_seconds"]
      assert_equal 1,  body["summary"].length
    end
  end

  # --- 週の移動 ---

  test "weekパラメータで前の週を表示できる" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 8, 10, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: Time.zone.local(2024, 4, 30, 9, 0), ended_at: Time.zone.local(2024, 4, 30, 10, 0))
      get "/api/weekly", params: { week: "2024-04-29" }
      body = response.parsed_body
      assert_equal "2024-04-29", body["week_start"]
      assert_equal 3600, body["total_seconds"]
    end
  end

  test "weekパラメータで未来の週を表示すると記録なしになる" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
      get "/api/weekly", params: { week: "2024-05-06" }
      body = response.parsed_body
      assert_equal [], body["summary"]
    end
  end

  # --- 先週比 ---

  test "レスポンスにprev_summaryが含まれる" do
    sign_in @user
    get "/api/weekly"
    assert response.parsed_body.key?("prev_summary")
  end

  test "先週の記録がprev_summaryに反映される" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 8, 10, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: Time.zone.local(2024, 4, 30, 9, 0), ended_at: Time.zone.local(2024, 4, 30, 10, 0))
      get "/api/weekly"
      prev = response.parsed_body["prev_summary"]
      assert_equal 1,  prev.length
      assert_equal 3600, prev.first["total_seconds"]
    end
  end

  # --- レスポンス形式 ---

  test "week_start・week_endが返る" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
      get "/api/weekly"
      body = response.parsed_body
      assert_equal "2024-04-29", body["week_start"]
      assert_equal "2024-05-05", body["week_end"]
    end
  end

  test "streak_daysが返る" do
    sign_in @user
    get "/api/weekly"
    assert response.parsed_body.key?("streak_days")
  end
end
