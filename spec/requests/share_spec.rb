# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Share', type: :request do
  let(:user)     { create(:user) }
  let(:activity) { create(:activity, user: user, name: '数学', icon: '📚') }

  describe '/share/daily/:token' do
    it '不正なdailyトークンは404を返す' do
      get '/share/daily/invalidtoken'
      expect(response).to have_http_status(:not_found)
    end

    it 'dailyページは未ログインでもアクセスできる' do
      link = create(:share_link, user: user, share_type: :daily, target_date: Date.new(2024, 5, 10))
      get "/share/daily/#{link.token}"
      expect(response).to have_http_status(:success)
    end

    it 'dailyページに日付が表示される' do
      link = create(:share_link, user: user, share_type: :daily, target_date: Date.new(2024, 5, 10))
      get "/share/daily/#{link.token}"
      expect(response.body).to match('2024年5月10日')
    end

    it 'dailyページに合計時間が表示される' do
      travel_to Time.zone.local(2024, 5, 10, 12, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.current - 2.hours, ended_at: Time.current)
        link = create(:share_link, user: user, share_type: :daily, target_date: Date.new(2024, 5, 10))
        get "/share/daily/#{link.token}"
        expect(response.body).to match('合計時間')
        expect(response.body).to match('2時間')
      end
    end

    it 'dailyページにカテゴリ名が表示される' do
      travel_to Time.zone.local(2024, 5, 10, 12, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.current - 1.hour, ended_at: Time.current)
        link = create(:share_link, user: user, share_type: :daily, target_date: Date.new(2024, 5, 10))
        get "/share/daily/#{link.token}"
        expect(response.body).to match('数学')
      end
    end

    it 'dailyページにOGPメタタグが含まれる' do
      link = create(:share_link, user: user, share_type: :daily, target_date: Date.new(2024, 5, 10))
      get "/share/daily/#{link.token}"
      expect(response.body).to match('property="og:title"')
      expect(response.body).to match('property="og:description"')
      expect(response.body).to match('property="og:image"')
    end

    it '記録なしのdailyページも正常に表示される' do
      link = create(:share_link, user: user, share_type: :daily, target_date: Date.new(2024, 1, 1))
      get "/share/daily/#{link.token}"
      expect(response).to have_http_status(:success)
      expect(response.body).to match('記録はありません')
    end
  end

  describe '/share/weekly/:token' do
    it '不正なweeklyトークンは404を返す' do
      get '/share/weekly/invalidtoken'
      expect(response).to have_http_status(:not_found)
    end

    it 'weeklyページは未ログインでもアクセスできる' do
      link = create(:share_link, user: user, share_type: :weekly, target_date: Date.new(2024, 5, 6))
      get "/share/weekly/#{link.token}"
      expect(response).to have_http_status(:success)
    end

    it 'weeklyページに週範囲が表示される' do
      link = create(:share_link, user: user, share_type: :weekly, target_date: Date.new(2024, 5, 6))
      get "/share/weekly/#{link.token}"
      expect(response.body).to match('2024年5月')
    end

    it 'weeklyページに合計時間が表示される' do
      travel_to Time.zone.local(2024, 5, 8, 12, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.current - 2.hours, ended_at: Time.current)
        link = create(:share_link, user: user, share_type: :weekly, target_date: Date.new(2024, 5, 6))
        get "/share/weekly/#{link.token}"
        expect(response.body).to match('合計時間')
        expect(response.body).to match('2時間')
      end
    end

    it 'weeklyページにカテゴリ名が表示される' do
      travel_to Time.zone.local(2024, 5, 8, 12, 0, 0) do
        create(:record, user: user, activity: activity,
               logged_at: Time.current - 1.hour, ended_at: Time.current)
        link = create(:share_link, user: user, share_type: :weekly, target_date: Date.new(2024, 5, 6))
        get "/share/weekly/#{link.token}"
        expect(response.body).to match('数学')
      end
    end

    it 'weeklyページにOGPメタタグが含まれる' do
      link = create(:share_link, user: user, share_type: :weekly, target_date: Date.new(2024, 5, 6))
      get "/share/weekly/#{link.token}"
      expect(response.body).to match('property="og:title"')
      expect(response.body).to match('property="og:description"')
      expect(response.body).to match('property="og:image"')
    end

    it '記録なしのweeklyページも正常に表示される' do
      link = create(:share_link, user: user, share_type: :weekly, target_date: Date.new(2024, 1, 1))
      get "/share/weekly/#{link.token}"
      expect(response).to have_http_status(:success)
      expect(response.body).to match('記録はありません')
    end

    it 'dailyトークンでweeklyにアクセスすると404になる' do
      link = create(:share_link, user: user, share_type: :daily, target_date: Date.new(2024, 5, 10))
      get "/share/weekly/#{link.token}"
      expect(response).to have_http_status(:not_found)
    end
  end
end
