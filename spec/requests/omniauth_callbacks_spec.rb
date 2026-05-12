# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OmniauthCallbacks', type: :request do
  before { OmniAuth.config.test_mode = true }

  after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.mock_auth[:github]        = nil
    OmniAuth.config.mock_auth[:twitter]       = nil
  end

  def build_auth_hash(provider, uid, email, nickname = 'testuser')
    OmniAuth::AuthHash.new(
      provider: provider,
      uid:      uid,
      info:     { email: email, name: nickname, nickname: nickname }
    )
  end

  describe 'Google' do
    it 'Google OAuth初回ログインでユーザーが作成されログインする' do
      OmniAuth.config.mock_auth[:google_oauth2] = build_auth_hash('google_oauth2', 'g001', 'google@example.com')
      expect {
        get '/users/auth/google_oauth2/callback'
      }.to change(User, :count).by(1)
      expect(response).to be_redirect
    end

    it 'Google OAuth 2回目ログインで既存ユーザーがログインする' do
      user = create(:user, provider: 'google_oauth2', uid: 'g001')
      OmniAuth.config.mock_auth[:google_oauth2] = build_auth_hash('google_oauth2', 'g001', user.email)
      expect {
        get '/users/auth/google_oauth2/callback'
      }.not_to change(User, :count)
      expect(response).to be_redirect
    end
  end

  describe 'GitHub' do
    it 'GitHub OAuth初回ログインでユーザーが作成される' do
      OmniAuth.config.mock_auth[:github] = build_auth_hash('github', 'gh001', 'github@example.com')
      expect {
        get '/users/auth/github/callback'
      }.to change(User, :count).by(1)
      expect(response).to be_redirect
    end

    it 'GitHubでemailなしの場合に仮メールでユーザーが作成される' do
      OmniAuth.config.mock_auth[:github] = build_auth_hash('github', 'gh002', nil, 'ghuser')
      expect {
        get '/users/auth/github/callback'
      }.to change(User, :count).by(1)
      created = User.find_by(provider: 'github', uid: 'gh002')
      expect(created.email).to match(/github_gh002@example\.invalid/)
    end
  end

  describe 'X (Twitter)' do
    it 'X OAuth初回ログインでユーザーが作成される' do
      OmniAuth.config.mock_auth[:twitter] = build_auth_hash('twitter', 'tw001', nil, 'xuser')
      expect {
        get '/users/auth/twitter/callback'
      }.to change(User, :count).by(1)
      expect(response).to be_redirect
    end
  end

  describe '認可拒否' do
    it '認可拒否時にログインページにリダイレクトされる' do
      OmniAuth.config.mock_auth[:github] = :access_denied
      get '/users/auth/github/callback'
      follow_redirect! while response.redirect?
      expect(request.path).to eq(new_user_session_path)
    end
  end
end
