# frozen_string_literal: true

require "test_helper"

class Api::DashboardLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user     = create(:user)
    @activity = create(:activity, user: @user)
    @headers  = { "Content-Type" => "application/json", "Accept" => "application/json" }
  end

  # --- 認証 ---

  test "未ログインは401を返す" do
    post "/api/dashboard/logs",
         params: { activity_id: @activity.public_id, logged_at: Time.current.iso8601 }.to_json,
         headers: @headers
    assert_response :unauthorized
  end

  # --- 記録追加 ---

  test "記録が作成される" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
      assert_difference("Record.count") do
        post "/api/dashboard/logs",
             params: { activity_id: @activity.public_id, logged_at: Time.current.iso8601 }.to_json,
             headers: @headers
      end
      assert_response :created
      body = response.parsed_body
      assert body["ok"]
      assert_equal @activity.name, body["record"]["activity"]["name"]
    end
  end

  test "記録時に前の計測中ログが終了される" do
    sign_in @user
    activity2 = create(:activity, user: @user)
    travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
      prev = create(:record, user: @user, activity: @activity,
                    logged_at: 30.minutes.ago, ended_at: nil)
      post "/api/dashboard/logs",
           params: { activity_id: activity2.public_id, logged_at: Time.current.iso8601 }.to_json,
           headers: @headers
      assert_not_nil prev.reload.ended_at
    end
  end

  test "レスポンスにsummary_per_categoryが含まれる" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
      post "/api/dashboard/logs",
           params: { activity_id: @activity.public_id, logged_at: Time.current.iso8601 }.to_json,
           headers: @headers
      assert response.parsed_body.key?("summary_per_category")
    end
  end
end
