# frozen_string_literal: true

require "test_helper"

class Api::DaysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user     = create(:user)
    @activity = create(:activity, user: @user)
  end

  # --- 認証 ---

  test "未ログインは401を返す" do
    get "/api/days/2024-05-01", headers: { "Accept" => "application/json" }
    assert_response :unauthorized
  end

  # --- 正常系 ---

  test "指定日の記録が返る" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 10, 10, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: Time.current - 1.hour, ended_at: Time.current)
      get "/api/days/2024-05-10"
      assert_response :success
      body = response.parsed_body
      assert_equal "2024-05-10", body["date"]
      assert_equal 3600, body["total_seconds"]
      assert_equal 1, body["per_category"].length
      assert_equal 1, body["logs"].length
    end
  end

  test "記録なしの日でもエラーにならない" do
    sign_in @user
    get "/api/days/2024-05-01"
    assert_response :success
    body = response.parsed_body
    assert_equal 0,  body["total_seconds"]
    assert_equal [], body["per_category"]
    assert_equal [], body["logs"]
  end

  test "per_categoryにsecondsとratioが含まれる" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 10, 10, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: Time.current - 1.hour, ended_at: Time.current)
      get "/api/days/2024-05-10"
      cat = response.parsed_body["per_category"].first
      assert cat.key?("seconds")
      assert cat.key?("ratio")
    end
  end

  # --- 異常系 ---

  test "不正な日付は400を返す" do
    sign_in @user
    get "/api/days/invalid-date"
    assert_response :bad_request
  end
end
