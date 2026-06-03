# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Weekly', type: :request do
  let(:user)     { create(:user) }
  let(:activity) { create(:activity, user: user) }

  describe '認証' do
    it '未ログインは401を返す' do
      get '/api/weekly', headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/weekly' do
    before { sign_in user }

    it '記録なしでもエラーにならない' do
      get '/api/weekly'
      expect(response).to have_http_status(:success)
      body = response.parsed_body
      expect(body['summary']).to eq([])
      expect(body['total_seconds']).to eq(0)
    end

    it '今週の記録が集計される' do
      travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.current - 1.hour, ended_at: Time.current)
        get '/api/weekly'
        body = response.parsed_body
        expect(body['total_seconds']).to eq(3600)
        expect(body['summary'].length).to eq(1)
      end
    end

    it 'weekパラメータで前の週を表示できる' do
      travel_to Time.zone.local(2024, 5, 8, 10, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.zone.local(2024, 4, 30, 9, 0),
               ended_at:  Time.zone.local(2024, 4, 30, 10, 0))
        get '/api/weekly', params: { week: '2024-04-29' }
        body = response.parsed_body
        expect(body['week_start']).to eq('2024-04-29')
        expect(body['total_seconds']).to eq(3600)
      end
    end

    it 'weekパラメータで未来の週を表示すると記録なしになる' do
      travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
        get '/api/weekly', params: { week: '2024-05-06' }
        expect(response.parsed_body['summary']).to eq([])
      end
    end

    it 'レスポンスにprev_summaryが含まれる' do
      get '/api/weekly'
      expect(response.parsed_body).to have_key('prev_summary')
    end

    it '先週の記録がprev_summaryに反映される' do
      travel_to Time.zone.local(2024, 5, 8, 10, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.zone.local(2024, 4, 30, 9, 0),
               ended_at:  Time.zone.local(2024, 4, 30, 10, 0))
        get '/api/weekly'
        prev = response.parsed_body['prev_summary']
        expect(prev.length).to eq(1)
        expect(prev.first['total_seconds']).to eq(3600)
      end
    end

    it 'week_start・week_endが返る' do
      travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
        get '/api/weekly'
        body = response.parsed_body
        expect(body['week_start']).to eq('2024-04-29')
        expect(body['week_end']).to eq('2024-05-05')
      end
    end

    it 'streak_daysが返る' do
      get '/api/weekly'
      expect(response.parsed_body).to have_key('streak_days')
    end
  end
end
