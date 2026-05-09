# frozen_string_literal: true

require "test_helper"

class ShareControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user     = create(:user)
    @activity = create(:activity, user: @user, name: "数学", icon: "📚")
  end

  # ===== /share/daily/:token =====

  test "不正なdailyトークンは404を返す" do
    get "/share/daily/invalidtoken"
    assert_response :not_found
  end

  test "dailyページは未ログインでもアクセスできる" do
    link = create(:share_link, user: @user, share_type: :daily, target_date: Date.new(2024, 5, 10))
    get "/share/daily/#{link.token}"
    assert_response :success
  end

  test "dailyページに日付が表示される" do
    link = create(:share_link, user: @user, share_type: :daily, target_date: Date.new(2024, 5, 10))
    get "/share/daily/#{link.token}"
    assert_response :success
    assert_match "2024年5月10日", response.body
  end

  test "dailyページに合計時間が表示される" do
    date = Date.new(2024, 5, 10)
    travel_to Time.zone.local(2024, 5, 10, 12, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: Time.current - 2.hours, ended_at: Time.current)
      link = create(:share_link, user: @user, share_type: :daily, target_date: date)
      get "/share/daily/#{link.token}"
      assert_response :success
      assert_match "合計時間", response.body
      assert_match "2時間", response.body
    end
  end

  test "dailyページにカテゴリ名が表示される" do
    date = Date.new(2024, 5, 10)
    travel_to Time.zone.local(2024, 5, 10, 12, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: Time.current - 1.hour, ended_at: Time.current)
      link = create(:share_link, user: @user, share_type: :daily, target_date: date)
      get "/share/daily/#{link.token}"
      assert_match "数学", response.body
    end
  end

  test "dailyページにOGPメタタグが含まれる" do
    link = create(:share_link, user: @user, share_type: :daily, target_date: Date.new(2024, 5, 10))
    get "/share/daily/#{link.token}"
    assert_match 'property="og:title"',       response.body
    assert_match 'property="og:description"', response.body
    assert_match 'property="og:image"',       response.body
  end

  test "dailyページのog:titleに日付が含まれる" do
    link = create(:share_link, user: @user, share_type: :daily, target_date: Date.new(2024, 5, 10))
    get "/share/daily/#{link.token}"
    assert_match "2024年5月10日", response.body
  end

  test "記録なしのdailyページも正常に表示される" do
    link = create(:share_link, user: @user, share_type: :daily, target_date: Date.new(2024, 1, 1))
    get "/share/daily/#{link.token}"
    assert_response :success
    assert_match "記録はありません", response.body
  end

  # ===== /share/weekly/:token =====

  test "不正なweeklyトークンは404を返す" do
    get "/share/weekly/invalidtoken"
    assert_response :not_found
  end

  test "weeklyページは未ログインでもアクセスできる" do
    link = create(:share_link, user: @user, share_type: :weekly, target_date: Date.new(2024, 5, 6))
    get "/share/weekly/#{link.token}"
    assert_response :success
  end

  test "weeklyページに週範囲が表示される" do
    link = create(:share_link, user: @user, share_type: :weekly, target_date: Date.new(2024, 5, 6))
    get "/share/weekly/#{link.token}"
    assert_response :success
    assert_match "2024年5月", response.body
  end

  test "weeklyページに合計時間が表示される" do
    travel_to Time.zone.local(2024, 5, 8, 12, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: Time.current - 2.hours, ended_at: Time.current)
      link = create(:share_link, user: @user, share_type: :weekly, target_date: Date.new(2024, 5, 6))
      get "/share/weekly/#{link.token}"
      assert_match "合計時間", response.body
      assert_match "2時間", response.body
    end
  end

  test "weeklyページにカテゴリ名が表示される" do
    travel_to Time.zone.local(2024, 5, 8, 12, 0, 0) do
      create(:record, user: @user, activity: @activity,
             logged_at: Time.current - 1.hour, ended_at: Time.current)
      link = create(:share_link, user: @user, share_type: :weekly, target_date: Date.new(2024, 5, 6))
      get "/share/weekly/#{link.token}"
      assert_match "数学", response.body
    end
  end

  test "weeklyページにOGPメタタグが含まれる" do
    link = create(:share_link, user: @user, share_type: :weekly, target_date: Date.new(2024, 5, 6))
    get "/share/weekly/#{link.token}"
    assert_match 'property="og:title"',       response.body
    assert_match 'property="og:description"', response.body
    assert_match 'property="og:image"',       response.body
  end

  test "記録なしのweeklyページも正常に表示される" do
    link = create(:share_link, user: @user, share_type: :weekly, target_date: Date.new(2024, 1, 1))
    get "/share/weekly/#{link.token}"
    assert_response :success
    assert_match "記録はありません", response.body
  end

  test "dailyトークンでweeklyにアクセスすると404になる" do
    link = create(:share_link, user: @user, share_type: :daily, target_date: Date.new(2024, 5, 10))
    get "/share/weekly/#{link.token}"
    assert_response :not_found
  end
end
