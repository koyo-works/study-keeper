# frozen_string_literal: true

require "test_helper"

class OmniauthCallbacksTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
  end

  teardown do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.mock_auth[:github]        = nil
    OmniAuth.config.mock_auth[:twitter]       = nil
  end

  # --- Google ---

  test "Google OAuth初回ログインでユーザーが作成されログインする" do
    OmniAuth.config.mock_auth[:google_oauth2] = build_auth_hash("google_oauth2", "g001", "google@example.com")
    assert_difference "User.count", 1 do
      get "/users/auth/google_oauth2/callback"
    end
    assert_response :redirect
  end

  test "Google OAuth 2回目ログインで既存ユーザーがログインする" do
    user = create(:user, provider: "google_oauth2", uid: "g001")
    OmniAuth.config.mock_auth[:google_oauth2] = build_auth_hash("google_oauth2", "g001", user.email)
    assert_no_difference "User.count" do
      get "/users/auth/google_oauth2/callback"
    end
    assert_response :redirect
  end

  # --- GitHub ---

  test "GitHub OAuth初回ログインでユーザーが作成される" do
    OmniAuth.config.mock_auth[:github] = build_auth_hash("github", "gh001", "github@example.com")
    assert_difference "User.count", 1 do
      get "/users/auth/github/callback"
    end
    assert_response :redirect
  end

  test "GitHubでemailなしの場合に仮メールでユーザーが作成される" do
    OmniAuth.config.mock_auth[:github] = build_auth_hash("github", "gh002", nil, "ghuser")
    assert_difference "User.count", 1 do
      get "/users/auth/github/callback"
    end
    created = User.find_by(provider: "github", uid: "gh002")
    assert_match /github_gh002@example\.invalid/, created.email
  end

  # --- X (Twitter) ---

  test "X OAuth初回ログインでユーザーが作成される" do
    OmniAuth.config.mock_auth[:twitter] = build_auth_hash("twitter", "tw001", nil, "xuser")
    assert_difference "User.count", 1 do
      get "/users/auth/twitter/callback"
    end
    assert_response :redirect
  end

  # --- 認可拒否 ---

  test "認可拒否時にログインページにリダイレクトされる" do
    OmniAuth.config.mock_auth[:github] = :access_denied
    get "/users/auth/github/callback"
    # OmniAuthはまず /users/auth/failure へリダイレクトし、
    # そこから failure アクションが new_user_session_path へリダイレクトする
    follow_redirect! while response.redirect?
    assert_equal new_user_session_path, path
  end

  private

  def build_auth_hash(provider, uid, email, nickname = "testuser")
    OmniAuth::AuthHash.new(
      provider: provider,
      uid:      uid,
      info:     { email: email, name: nickname, nickname: nickname }
    )
  end
end
