# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe '新規登録' do
    it '新規登録できる' do
      expect {
        post user_registration_path, params: {
          user: {
            name:                  'テストユーザー',
            email:                 'newuser@example.com',
            password:              'password123',
            password_confirmation: 'password123'
          }
        }
      }.to change(User, :count).by(1)
      expect(response).to be_redirect
    end

    it 'nameなし登録はエラーになる' do
      expect {
        post user_registration_path, params: {
          user: {
            name:                  '',
            email:                 'newuser@example.com',
            password:              'password123',
            password_confirmation: 'password123'
          }
        }
      }.not_to change(User, :count)
    end

    it 'メールアドレス重複登録はエラーになる' do
      existing = create(:user)
      expect {
        post user_registration_path, params: {
          user: {
            name:                  '別のユーザー',
            email:                 existing.email,
            password:              'password123',
            password_confirmation: 'password123'
          }
        }
      }.not_to change(User, :count)
    end

    it 'パスワード不一致はエラーになる' do
      expect {
        post user_registration_path, params: {
          user: {
            name:                  'テストユーザー',
            email:                 'newuser@example.com',
            password:              'password123',
            password_confirmation: 'wrongpass'
          }
        }
      }.not_to change(User, :count)
    end
  end

  describe 'ログイン' do
    it '正しい認証情報でログインできる' do
      user = create(:user, password: 'password123')
      post user_session_path, params: {
        user: { email: user.email, password: 'password123' }
      }
      expect(response).to be_redirect
      follow_redirect!
      expect(response).to have_http_status(:success)
    end

    it '誤ったパスワードはログインできない' do
      user = create(:user, password: 'password123')
      post user_session_path, params: {
        user: { email: user.email, password: 'wrongpass' }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'ログアウト' do
    it 'ログアウトできる' do
      user = create(:user)
      sign_in user
      delete destroy_user_session_path
      expect(response).to be_redirect
      follow_redirect!
      expect(response).to have_http_status(:success)
    end
  end

  describe 'アクセス制御' do
    it '未ログインでダッシュボードにアクセスするとリダイレクトされる' do
      get learning_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it '未ログインで週次画面にアクセスするとリダイレクトされる' do
      get weekly_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it '未ログインで月次画面にアクセスするとリダイレクトされる' do
      get monthly_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it '未ログインで設定画面にアクセスするとリダイレクトされる' do
      get settings_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'ログイン済みでダッシュボードにアクセスできる' do
      sign_in create(:user)
      get learning_path
      expect(response).to have_http_status(:success)
    end
  end
end
