# frozen_string_literal: true

require "test_helper"

class Api::DashboardStopControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user     = create(:user)
    @activity = create(:activity, user: @user)
    @headers  = { "Content-Type" => "application/json", "Accept" => "application/json" }
  end

  # --- 認証 ---

  test "未ログインは401を返す" do
    post "/api/dashboard/stop",
         params: { ended_at: Time.current.iso8601 }.to_json,
         headers: @headers
    assert_response :unauthorized
  end

  # --- 計測停止 ---

  test "計測中のログが終了される" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
      record = create(:record, user: @user, activity: @activity,
                      logged_at: 30.minutes.ago, ended_at: nil)
      post "/api/dashboard/stop",
           params: { ended_at: Time.current.iso8601 }.to_json,
           headers: @headers
      assert_response :success
      assert_not_nil record.reload.ended_at
    end
  end

  test "レスポンスにrecordとsummary_per_categoryが含まれる" do
    sign_in @user
    travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: 30.minutes.ago, ended_at: nil)
      post "/api/dashboard/stop",
           params: { ended_at: Time.current.iso8601 }.to_json,
           headers: @headers
      body = response.parsed_body
      assert body.key?("record")
      assert body.key?("summary_per_category")
    end
  end

  test "計測中のログがないときは422を返す" do
    sign_in @user
    post "/api/dashboard/stop",
         params: { ended_at: Time.current.iso8601 }.to_json,
         headers: @headers
    assert_response :unprocessable_entity
  end
end
