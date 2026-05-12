# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Days', type: :request do
  let(:user)     { create(:user) }
  let(:activity) { create(:activity, user: user) }

  describe '認証' do
    it '未ログインは401を返す' do
      get '/api/days/2024-05-01', headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/days/:date' do
    before { sign_in user }

    it '指定日の記録が返る' do
      travel_to Time.zone.local(2024, 5, 10, 10, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.current - 1.hour, ended_at: Time.current)
        get '/api/days/2024-05-10'
        expect(response).to have_http_status(:success)
        body = response.parsed_body
        expect(body['date']).to eq('2024-05-10')
        expect(body['total_seconds']).to eq(3600)
        expect(body['per_category'].length).to eq(1)
        expect(body['logs'].length).to eq(1)
      end
    end

    it '記録なしの日でもエラーにならない' do
      get '/api/days/2024-05-01'
      expect(response).to have_http_status(:success)
      body = response.parsed_body
      expect(body['total_seconds']).to eq(0)
      expect(body['per_category']).to eq([])
      expect(body['logs']).to eq([])
    end

    it 'per_categoryにsecondsとratioが含まれる' do
      travel_to Time.zone.local(2024, 5, 10, 10, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.current - 1.hour, ended_at: Time.current)
        get '/api/days/2024-05-10'
        cat = response.parsed_body['per_category'].first
        expect(cat).to have_key('seconds')
        expect(cat).to have_key('ratio')
      end
    end

    it '複数行動の合計秒数が正しく集計される' do
      activity2 = create(:activity, user: user)
      travel_to Time.zone.local(2024, 5, 10, 12, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.current - 2.hours, ended_at: Time.current - 1.hour)
        create(:record, user: user, activity: activity2,
               logged_at: Time.current - 1.hour, ended_at: Time.current)
        get '/api/days/2024-05-10'
        body = response.parsed_body
        expect(body['total_seconds']).to eq(7200)
        expect(body['per_category'].length).to eq(2)
      end
    end

    it 'per_categoryは秒数の多い順に並ぶ' do
      activity2 = create(:activity, user: user)
      travel_to Time.zone.local(2024, 5, 10, 12, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.current - 3.hours, ended_at: Time.current - 2.hours)
        create(:record, user: user, activity: activity2,
               logged_at: Time.current - 2.hours, ended_at: Time.current)
        get '/api/days/2024-05-10'
        cats = response.parsed_body['per_category']
        expect(cats.first['name']).to eq(activity2.name)
      end
    end

    it 'per_categoryの割合が合計に対して正しく計算される' do
      activity2 = create(:activity, user: user)
      travel_to Time.zone.local(2024, 5, 10, 12, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.current - 2.hours, ended_at: Time.current - 1.hour)
        create(:record, user: user, activity: activity2,
               logged_at: Time.current - 1.hour, ended_at: Time.current)
        get '/api/days/2024-05-10'
        cats = response.parsed_body['per_category']
        expect(cats.first['ratio']).to eq(50)
        expect(cats.last['ratio']).to eq(50)
      end
    end

    it '他の日の記録は集計に含まれない' do
      travel_to Time.zone.local(2024, 5, 10, 10, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.zone.local(2024, 5, 9, 9, 0),
               ended_at:  Time.zone.local(2024, 5, 9, 10, 0))
        get '/api/days/2024-05-10'
        expect(response.parsed_body['total_seconds']).to eq(0)
      end
    end

    it 'per_categoryにactivity_idが含まれる' do
      travel_to Time.zone.local(2024, 5, 10, 10, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.current - 1.hour, ended_at: Time.current)
        get '/api/days/2024-05-10'
        cat = response.parsed_body['per_category'].first
        expect(cat).to have_key('activity_id')
        expect(cat['activity_id']).to eq(activity.public_id.to_s)
      end
    end

    it '不正な日付は400を返す' do
      get '/api/days/invalid-date'
      expect(response).to have_http_status(:bad_request)
    end
  end
end
