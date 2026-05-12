# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Monthly', type: :request do
  let(:user)     { create(:user) }
  let(:activity) { create(:activity, user: user) }

  describe '認証' do
    it '未ログインは401を返す' do
      get '/api/monthly', headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/monthly' do
    before { sign_in user }

    it '記録なしでもエラーにならない' do
      get '/api/monthly'
      expect(response).to have_http_status(:success)
      expect(response.parsed_body['daily_summaries']).to eq({})
    end

    it '当月の開始・終了日が返る' do
      travel_to Time.zone.local(2024, 5, 15, 10, 0, 0) do
        get '/api/monthly'
        body = response.parsed_body
        expect(body['month_start']).to eq('2024-05-01')
        expect(body['month_end']).to eq('2024-05-31')
      end
    end

    it 'monthパラメータで前月を表示できる' do
      get '/api/monthly', params: { month: '2024-04' }
      body = response.parsed_body
      expect(body['month_start']).to eq('2024-04-01')
      expect(body['month_end']).to eq('2024-04-30')
    end

    it '記録のある日にdaily_summariesが作られる' do
      travel_to Time.zone.local(2024, 5, 10, 10, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.current - 1.hour, ended_at: Time.current)
        get '/api/monthly'
        expect(response.parsed_body['daily_summaries']).to have_key('2024-05-10')
      end
    end

    it 'dominant_categoryは最も時間の多い行動名になる' do
      activity2 = create(:activity, user: user)
      travel_to Time.zone.local(2024, 5, 10, 12, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.current - 30.minutes, ended_at: Time.current)
        create(:record, user: user, activity: activity2,
               logged_at: Time.current - 2.hours, ended_at: Time.current - 30.minutes)
        get '/api/monthly'
        dominant = response.parsed_body['daily_summaries']['2024-05-10']['dominant_category']
        expect(dominant).to eq(activity2.name)
      end
    end

    it '記録のない日はdaily_summariesに含まれない' do
      travel_to Time.zone.local(2024, 5, 10, 10, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.current - 1.hour, ended_at: Time.current)
        get '/api/monthly'
        expect(response.parsed_body['daily_summaries']).not_to have_key('2024-05-09')
      end
    end

    it '先月の記録は当月のdaily_summariesに含まれない' do
      travel_to Time.zone.local(2024, 5, 10, 10, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.zone.local(2024, 4, 30, 9, 0),
               ended_at:  Time.zone.local(2024, 4, 30, 10, 0))
        get '/api/monthly'
        expect(response.parsed_body['daily_summaries']).to eq({})
      end
    end

    it 'daily_summariesにtotal_secondsが含まれる' do
      travel_to Time.zone.local(2024, 5, 10, 10, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.current - 1.hour, ended_at: Time.current)
        get '/api/monthly'
        day = response.parsed_body['daily_summaries']['2024-05-10']
        expect(day).to have_key('total_seconds')
        expect(day['total_seconds']).to eq(3600)
      end
    end
  end
end
