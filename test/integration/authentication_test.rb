# frozen_string_literal: true

require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  # --- 新規登録 ---

  test "新規登録できる" do
    assert_difference "User.count", 1 do
      post user_registration_path, params: {
        user: {
          name:                  "テストユーザー",
          email:                 "newuser@example.com",
          password:              "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "nameなし登録はエラーになる" do
    assert_no_difference "User.count" do
      post user_registration_path, params: {
        user: {
          name:                  "",
          email:                 "newuser@example.com",
          password:              "password123",
          password_confirmation: "password123"
        }
      }
    end
  end

  test "メールアドレス重複登録はエラーになる" do
    existing = create(:user)
    assert_no_difference "User.count" do
      post user_registration_path, params: {
        user: {
          name:                  "別のユーザー",
          email:                 existing.email,
          password:              "password123",
          password_confirmation: "password123"
        }
      }
    end
  end

  test "パスワード不一致はエラーになる" do
    assert_no_difference "User.count" do
      post user_registration_path, params: {
        user: {
          name:                  "テストユーザー",
          email:                 "newuser@example.com",
          password:              "password123",
          password_confirmation: "wrongpass"
        }
      }
    end
  end

  # --- ログイン ---

  test "正しい認証情報でログインできる" do
    user = create(:user, password: "password123")
    post user_session_path, params: {
      user: { email: user.email, password: "password123" }
    }
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "誤ったパスワードはログインできない" do
    user = create(:user, password: "password123")
    post user_session_path, params: {
      user: { email: user.email, password: "wrongpass" }
    }
    assert_response :unprocessable_entity
  end

  # --- ログアウト ---

  test "ログアウトできる" do
    user = create(:user)
    sign_in user
    delete destroy_user_session_path
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  # --- アクセス制御 ---

  test "未ログインでダッシュボードにアクセスするとリダイレクトされる" do
    get learning_path
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "未ログインで週次画面にアクセスするとリダイレクトされる" do
    get weekly_path
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "未ログインで月次画面にアクセスするとリダイレクトされる" do
    get monthly_path
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "未ログインで設定画面にアクセスするとリダイレクトされる" do
    get settings_path
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "ログイン済みでダッシュボードにアクセスできる" do
    sign_in create(:user)
    get learning_path
    assert_response :success
  end
end
