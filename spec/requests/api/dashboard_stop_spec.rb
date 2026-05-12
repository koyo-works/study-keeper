# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::DashboardStop', type: :request do
  let(:user)     { create(:user) }
  let(:activity) { create(:activity, user: user) }
  let(:headers)  { { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }

  describe '認証' do
    it '未ログインは401を返す' do
      post '/api/dashboard/stop',
           params: { ended_at: Time.current.iso8601 }.to_json,
           headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /api/dashboard/stop' do
    before { sign_in user }

    it '計測中のログが終了される' do
      travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
        record = create(:record, user: user, activity: activity,
                        logged_at: 30.minutes.ago, ended_at: nil)
        post '/api/dashboard/stop',
             params: { ended_at: Time.current.iso8601 }.to_json,
             headers: headers
        expect(response).to have_http_status(:success)
        expect(record.reload.ended_at).not_to be_nil
      end
    end

    it 'レスポンスにrecordとsummary_per_categoryが含まれる' do
      travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: 30.minutes.ago, ended_at: nil)
        post '/api/dashboard/stop',
             params: { ended_at: Time.current.iso8601 }.to_json,
             headers: headers
        body = response.parsed_body
        expect(body).to have_key('record')
        expect(body).to have_key('summary_per_category')
      end
    end

    it '計測中のログがないときは422を返す' do
      post '/api/dashboard/stop',
           params: { ended_at: Time.current.iso8601 }.to_json,
           headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
