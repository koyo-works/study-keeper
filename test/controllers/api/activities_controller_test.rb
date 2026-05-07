# frozen_string_literal: true

require "test_helper"

class Api::ActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user     = create(:user)
    @activity = create(:activity, user: @user, name: "数学", active: true)
  end

  # --- 認証 ---

  test "未ログインは401を返す (index)" do
    get "/api/activities", headers: { "Accept" => "application/json" }
    assert_response :unauthorized
  end

  test "未ログインは401を返す (create)" do
    post "/api/activities", params: { activity: { name: "英語", icon: "📝" } }, as: :json
    assert_response :unauthorized
  end

  # --- index ---

  test "アクティブなカテゴリ一覧が返る" do
    sign_in @user
    get "/api/activities"
    assert_response :success
    body = response.parsed_body
    assert_equal 1, body.length
    assert_equal "数学", body.first["name"]
  end

  test "非アクティブなカテゴリはindexに含まれない" do
    sign_in @user
    create(:activity, user: @user, name: "理科", active: false)
    get "/api/activities"
    names = response.parsed_body.map { |a| a["name"] }
    assert_not_includes names, "理科"
  end

  test "他ユーザーのカテゴリは含まれない" do
    other = create(:user)
    create(:activity, user: other, name: "他人の科目")
    sign_in @user
    get "/api/activities"
    names = response.parsed_body.map { |a| a["name"] }
    assert_not_includes names, "他人の科目"
  end

  # --- create ---

  test "カテゴリを新規作成できる" do
    sign_in @user
    assert_difference "Activity.count", 1 do
      post "/api/activities", params: { activity: { name: "英語", icon: "📝" } }, as: :json
    end
    assert_response :created
    body = response.parsed_body
    assert_equal "英語", body["name"]
    assert_equal "📝",  body["icon"]
  end

  test "nameなしはエラーになる" do
    sign_in @user
    post "/api/activities", params: { activity: { name: "", icon: "📝" } }, as: :json
    assert_response :unprocessable_entity
    assert response.parsed_body.key?("errors")
  end

  # --- update (active ON/OFF) ---

  test "カテゴリをOFFにできる" do
    sign_in @user
    patch "/api/activities/#{@activity.id}", params: { active: false }, as: :json
    assert_response :success
    assert_equal false, @activity.reload.active
  end

  test "カテゴリをONに戻せる" do
    sign_in @user
    @activity.update!(active: false)
    patch "/api/activities/#{@activity.id}", params: { active: true }, as: :json
    assert_response :success
    assert_equal true, @activity.reload.active
  end

  test "他ユーザーのカテゴリは更新できない" do
    other     = create(:user)
    other_act = create(:activity, user: other)
    sign_in @user
    patch "/api/activities/#{other_act.id}", params: { active: false }, as: :json
    assert_response :not_found
  end

  # --- destroy ---

  test "カテゴリを削除できる" do
    sign_in @user
    assert_difference "Activity.count", -1 do
      delete "/api/activities/#{@activity.id}", as: :json
    end
    assert_response :success
  end

  test "他ユーザーのカテゴリは削除できない" do
    other     = create(:user)
    other_act = create(:activity, user: other)
    sign_in @user
    delete "/api/activities/#{other_act.id}", as: :json
    assert_response :not_found
  end
end
