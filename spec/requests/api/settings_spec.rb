# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Settings', type: :request do
  let(:user) { create(:user) }

  describe '認証' do
    it '未ログインは401を返す (show)' do
      get '/api/settings', headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)
    end

    it '未ログインは401を返す (update)' do
      patch '/api/settings', params: { default_page: 'weekly' }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/settings' do
    before { sign_in user }

    it '設定情報が返る' do
      get '/api/settings'
      expect(response).to have_http_status(:success)
      body = response.parsed_body
      expect(body).to have_key('name')
      expect(body).to have_key('email')
      expect(body).to have_key('categories')
      expect(body).to have_key('default_page')
    end

    it 'カテゴリ一覧が含まれる' do
      create(:activity, user: user, name: '数学', active: true)
      create(:activity, user: user, name: '英語', active: false)
      get '/api/settings'
      body = response.parsed_body
      expect(body['categories'].length).to eq(2)
      cat_names = body['categories'].map { |c| c['name'] }
      expect(cat_names).to include('数学', '英語')
    end

    it 'カテゴリにactive属性が含まれる' do
      create(:activity, user: user, active: true)
      get '/api/settings'
      cat = response.parsed_body['categories'].first
      expect(cat).to have_key('active')
      expect(cat['active']).to be true
    end

    it '他ユーザーのカテゴリは含まれない' do
      other = create(:user)
      create(:activity, user: other, name: '他人の活動')
      get '/api/settings'
      cat_names = response.parsed_body['categories'].map { |c| c['name'] }
      expect(cat_names).not_to include('他人の活動')
    end

    it 'default_pageのデフォルトはdailyである' do
      get '/api/settings'
      expect(response.parsed_body['default_page']).to eq('daily')
    end
  end

  describe 'PATCH /api/settings' do
    before { sign_in user }

    it 'default_pageを変更できる' do
      patch '/api/settings', params: { default_page: 'weekly' }, as: :json
      expect(response).to have_http_status(:success)
      expect(response.parsed_body['default_page']).to eq('weekly')
      expect(user.reload.default_page).to eq('weekly')
    end

    it 'default_pageの変更がDBに永続化される' do
      patch '/api/settings', params: { default_page: 'monthly' }, as: :json
      expect(user.reload.default_page).to eq('monthly')
    end
  end
end
