# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::DashboardLogs', type: :request do
  let(:user)     { create(:user) }
  let(:activity) { create(:activity, user: user) }
  let(:headers)  { { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }

  describe '認証' do
    it '未ログインは401を返す' do
      post '/api/dashboard/logs',
           params: { activity_id: activity.public_id, logged_at: Time.current.iso8601 }.to_json,
           headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /api/dashboard/logs' do
    before { sign_in user }

    it '記録が作成される' do
      travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
        expect {
          post '/api/dashboard/logs',
               params: { activity_id: activity.public_id, logged_at: Time.current.iso8601 }.to_json,
               headers: headers
        }.to change(Record, :count).by(1)
        expect(response).to have_http_status(:created)
        body = response.parsed_body
        expect(body['ok']).to be true
        expect(body['record']['activity']['name']).to eq(activity.name)
      end
    end

    it '記録時に前の計測中ログが終了される' do
      activity2 = create(:activity, user: user)
      travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
        prev = create(:record, user: user, activity: activity,
                      logged_at: 30.minutes.ago, ended_at: nil)
        post '/api/dashboard/logs',
             params: { activity_id: activity2.public_id, logged_at: Time.current.iso8601 }.to_json,
             headers: headers
        expect(prev.reload.ended_at).not_to be_nil
      end
    end

    it 'レスポンスにsummary_per_categoryが含まれる' do
      travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
        post '/api/dashboard/logs',
             params: { activity_id: activity.public_id, logged_at: Time.current.iso8601 }.to_json,
             headers: headers
        expect(response.parsed_body).to have_key('summary_per_category')
      end
    end
  end
end
