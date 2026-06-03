# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Dashboard', type: :request do
  let(:user)     { create(:user) }
  let(:activity) { create(:activity, user: user) }

  describe '認証' do
    it '未ログインは401を返す' do
      get '/api/dashboard/today', headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/dashboard/today' do
    before { sign_in user }

    it '記録がなくてもエラーにならない' do
      get '/api/dashboard/today'
      expect(response).to have_http_status(:success)
      body = response.parsed_body
      expect(body['logs']).to eq([])
      expect(body['summary_per_category']).to eq([])
      expect(body['current_log']).to be_nil
    end

    it '今日の記録が返る' do
      travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: 1.hour.ago, ended_at: Time.current)
        get '/api/dashboard/today'
        expect(response.parsed_body['logs'].length).to eq(1)
      end
    end

    it '昨日の記録はlogsに含まれない' do
      travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: 1.day.ago, ended_at: 1.day.ago + 30.minutes)
        get '/api/dashboard/today'
        expect(response.parsed_body['logs']).to eq([])
      end
    end

    it 'ended_atなしの記録はcurrent_logになる' do
      travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
        record = create(:record, user: user, activity: activity,
                        logged_at: 30.minutes.ago, ended_at: nil)
        get '/api/dashboard/today'
        body = response.parsed_body
        expect(body['current_log']).not_to be_nil
        expect(body['current_log']['id']).to eq(record.public_id.to_s)
      end
    end

    it 'ended_atありの記録はcurrent_logにならない' do
      travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: 1.hour.ago, ended_at: Time.current)
        get '/api/dashboard/today'
        expect(response.parsed_body['current_log']).to be_nil
      end
    end

    it 'ended_atから経過時間を計算する' do
      travel_to Time.zone.local(2024, 5, 1, 10, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: 30.minutes.ago, ended_at: Time.current)
        get '/api/dashboard/today'
        summary = response.parsed_body['summary_per_category'].first
        expect(summary['total_seconds']).to eq(1800)
      end
    end

    it '43200秒(12時間)を超える場合は43200秒に丸める' do
      travel_to Time.zone.local(2024, 5, 1, 23, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.current.beginning_of_day, ended_at: Time.current)
        get '/api/dashboard/today'
        summary = response.parsed_body['summary_per_category'].first
        expect(summary['total_seconds']).to eq(43200)
      end
    end

    it '前日23:30開始のログはlogsに含まれないがcurrent_logになる' do
      travel_to Time.zone.local(2024, 5, 2, 0, 30, 0) do
        record = create(:record, user: user, activity: activity,
                        logged_at: Time.zone.local(2024, 5, 1, 23, 30, 0), ended_at: nil)
        get '/api/dashboard/today'
        body = response.parsed_body
        expect(body['logs']).to eq([])
        expect(body['current_log']['id']).to eq(record.public_id.to_s)
      end
    end

    it '深夜帯に6時間以上前のログはcurrent_logにならない' do
      travel_to Time.zone.local(2024, 5, 2, 2, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: 7.hours.ago, ended_at: nil)
        get '/api/dashboard/today'
        expect(response.parsed_body['current_log']).to be_nil
      end
    end
  end
end
