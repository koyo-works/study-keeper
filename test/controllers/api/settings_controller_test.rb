# frozen_string_literal: true

require "test_helper"

class Api::SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  # --- 認証 ---

  test "未ログインは401を返す (show)" do
    get "/api/settings", headers: { "Accept" => "application/json" }
    assert_response :unauthorized
  end

  test "未ログインは401を返す (update)" do
    patch "/api/settings", params: { default_page: "weekly" }, as: :json
    assert_response :unauthorized
  end

  # --- show ---

  test "設定情報が返る" do
    sign_in @user
    get "/api/settings"
    assert_response :success
    body = response.parsed_body
    assert body.key?("name")
    assert body.key?("email")
    assert body.key?("categories")
    assert body.key?("default_page")
  end

  test "カテゴリ一覧が含まれる" do
    sign_in @user
    create(:activity, user: @user, name: "数学", active: true)
    create(:activity, user: @user, name: "英語", active: false)
    get "/api/settings"
    body = response.parsed_body
    assert_equal 2, body["categories"].length
    cat_names = body["categories"].map { |c| c["name"] }
    assert_includes cat_names, "数学"
    assert_includes cat_names, "英語"
  end

  test "カテゴリにactive属性が含まれる" do
    sign_in @user
    create(:activity, user: @user, active: true)
    get "/api/settings"
    cat = response.parsed_body["categories"].first
    assert cat.key?("active")
    assert_equal true, cat["active"]
  end

  test "他ユーザーのカテゴリは含まれない" do
    other = create(:user)
    create(:activity, user: other, name: "他人の活動")
    sign_in @user
    get "/api/settings"
    cat_names = response.parsed_body["categories"].map { |c| c["name"] }
    assert_not_includes cat_names, "他人の活動"
  end

  test "default_pageのデフォルトはdailyである" do
    sign_in @user
    get "/api/settings"
    assert_equal "daily", response.parsed_body["default_page"]
  end

  # --- update ---

  test "default_pageを変更できる" do
    sign_in @user
    patch "/api/settings", params: { default_page: "weekly" }, as: :json
    assert_response :success
    assert_equal "weekly", response.parsed_body["default_page"]
    assert_equal "weekly", @user.reload.default_page
  end

  test "default_pageの変更がDBに永続化される" do
    sign_in @user
    patch "/api/settings", params: { default_page: "monthly" }, as: :json
    @user.reload
    assert_equal "monthly", @user.default_page
  end
end
