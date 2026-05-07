# frozen_string_literal: true

require "test_helper"

class PasswordTest < ActionDispatch::IntegrationTest
  setup do
    ActionMailer::Base.deliveries.clear
  end

  # --- パスワード変更（アカウント編集） ---

  test "ログイン済みユーザーがパスワードを変更できる" do
    user = create(:user, password: "oldpassword1")
    sign_in user
    patch user_registration_path, params: {
      user: {
        current_password:      "oldpassword1",
        password:              "newpassword1",
        password_confirmation: "newpassword1"
      }
    }
    assert_response :redirect
    assert user.reload.valid_password?("newpassword1")
  end

  test "現在のパスワードが誤っていると変更できない" do
    user = create(:user, password: "oldpassword1")
    sign_in user
    patch user_registration_path, params: {
      user: {
        current_password:      "wrongpassword",
        password:              "newpassword1",
        password_confirmation: "newpassword1"
      }
    }
    assert user.reload.valid_password?("oldpassword1")
  end

  test "新しいパスワードが不一致だと変更できない" do
    user = create(:user, password: "oldpassword1")
    sign_in user
    patch user_registration_path, params: {
      user: {
        current_password:      "oldpassword1",
        password:              "newpassword1",
        password_confirmation: "differentpass"
      }
    }
    assert user.reload.valid_password?("oldpassword1")
  end

  # --- パスワードリセット要求 ---

  test "パスワードリセット要求でメールが送信される" do
    user = create(:user)
    post user_password_path, params: { user: { email: user.email } }
    assert_response :redirect
    assert_equal 1, ActionMailer::Base.deliveries.count
  end

  test "存在しないメールアドレスでリセット要求してもメールは送られない" do
    post user_password_path, params: { user: { email: "notexist@example.com" } }
    assert_equal 0, ActionMailer::Base.deliveries.count
  end

  # --- トークンによるパスワード再設定 ---

  test "有効なトークンでパスワードを再設定できる" do
    user = create(:user)
    raw_token = user.send_reset_password_instructions
    put user_password_path, params: {
      user: {
        reset_password_token:  raw_token,
        password:              "resetpass1",
        password_confirmation: "resetpass1"
      }
    }
    assert_response :redirect
    assert user.reload.valid_password?("resetpass1")
  end

  test "不正なトークンではパスワードを再設定できない" do
    user = create(:user, password: "oldpassword1")
    put user_password_path, params: {
      user: {
        reset_password_token:  "invalidtoken",
        password:              "newpassword1",
        password_confirmation: "newpassword1"
      }
    }
    assert_response :unprocessable_entity
    assert user.reload.valid_password?("oldpassword1")
  end

  test "期限切れトークンではパスワードを再設定できない" do
    user = create(:user, password: "oldpassword1")
    raw_token = user.send_reset_password_instructions
    travel(Devise.reset_password_within + 1.second) do
      put user_password_path, params: {
        user: {
          reset_password_token:  raw_token,
          password:              "newpassword1",
          password_confirmation: "newpassword1"
        }
      }
      assert_response :unprocessable_entity
      assert user.reload.valid_password?("oldpassword1")
    end
  end
end
