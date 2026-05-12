# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Activities', type: :request do
  let(:user)     { create(:user) }
  let(:activity) { create(:activity, user: user, name: '数学', active: true) }

  describe '認証' do
    it '未ログインは401を返す (index)' do
      get '/api/activities', headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)
    end

    it '未ログインは401を返す (create)' do
      post '/api/activities', params: { activity: { name: '英語', icon: '📝' } }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/activities' do
    before { sign_in user }

    it 'アクティブなカテゴリ一覧が返る' do
      activity
      get '/api/activities'
      expect(response).to have_http_status(:success)
      body = response.parsed_body
      expect(body.length).to eq(1)
      expect(body.first['name']).to eq('数学')
    end

    it '非アクティブなカテゴリはindexに含まれない' do
      create(:activity, user: user, name: '理科', active: false)
      get '/api/activities'
      names = response.parsed_body.map { |a| a['name'] }
      expect(names).not_to include('理科')
    end

    it '他ユーザーのカテゴリは含まれない' do
      other = create(:user)
      create(:activity, user: other, name: '他人の科目')
      get '/api/activities'
      names = response.parsed_body.map { |a| a['name'] }
      expect(names).not_to include('他人の科目')
    end
  end

  describe 'POST /api/activities' do
    before { sign_in user }

    it 'カテゴリを新規作成できる' do
      expect {
        post '/api/activities', params: { activity: { name: '英語', icon: '📝' } }, as: :json
      }.to change(Activity, :count).by(1)
      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body['name']).to eq('英語')
      expect(body['icon']).to eq('📝')
    end

    it 'nameなしはエラーになる' do
      post '/api/activities', params: { activity: { name: '', icon: '📝' } }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to have_key('errors')
    end
  end

  describe 'PATCH /api/activities/:id' do
    before { sign_in user }

    it 'カテゴリをOFFにできる' do
      patch "/api/activities/#{activity.id}", params: { active: false }, as: :json
      expect(response).to have_http_status(:success)
      expect(activity.reload.active).to be false
    end

    it 'カテゴリをONに戻せる' do
      activity.update!(active: false)
      patch "/api/activities/#{activity.id}", params: { active: true }, as: :json
      expect(response).to have_http_status(:success)
      expect(activity.reload.active).to be true
    end

    it '他ユーザーのカテゴリは更新できない' do
      other     = create(:user)
      other_act = create(:activity, user: other)
      patch "/api/activities/#{other_act.id}", params: { active: false }, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/activities/:id' do
    before { sign_in user }

    it 'カテゴリを削除できる' do
      activity
      expect {
        delete "/api/activities/#{activity.id}", as: :json
      }.to change(Activity, :count).by(-1)
      expect(response).to have_http_status(:success)
    end

    it '他ユーザーのカテゴリは削除できない' do
      other     = create(:user)
      other_act = create(:activity, user: other)
      delete "/api/activities/#{other_act.id}", as: :json
      expect(response).to have_http_status(:not_found)
    end
  end
end
