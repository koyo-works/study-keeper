# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeeklySummaryService do
  let(:user)     { create(:user) }
  let(:activity) { create(:activity, user: user) }

  it '記録なしは空配列を返す' do
    expect(WeeklySummaryService.new([]).call).to eq([])
  end

  it 'ended_atから時間を計算する' do
    logs = [
      create(:record, user: user, activity: activity,
             logged_at: Time.zone.local(2024, 5, 1, 9, 0),
             ended_at:  Time.zone.local(2024, 5, 1, 10, 0))
    ]
    result = WeeklySummaryService.new(logs).call
    expect(result.first[:total_seconds]).to eq(3600)
  end

  it 'ended_atを次のlogged_atより優先する' do
    activity2 = create(:activity, user: user)
    t1 = Time.zone.local(2024, 5, 1, 9, 0)
    log1 = create(:record, user: user, activity: activity,
                  logged_at: t1, ended_at: t1 + 30.minutes)
    log2 = create(:record, user: user, activity: activity2,
                  logged_at: t1 + 50.minutes, ended_at: t1 + 60.minutes)
    result = WeeklySummaryService.new([log1, log2]).call
    entry = result.find { |s| s[:activity_id] == activity.public_id }
    expect(entry[:total_seconds]).to eq(1800)
  end

  it 'ended_atなし・同日の次ログありは次のlogged_atで計算する' do
    activity2 = create(:activity, user: user)
    t1 = Time.zone.local(2024, 5, 1, 9, 0)
    log1 = create(:record, user: user, activity: activity,
                  logged_at: t1, ended_at: nil)
    log2 = create(:record, user: user, activity: activity2,
                  logged_at: t1 + 45.minutes, ended_at: t1 + 60.minutes)
    result = WeeklySummaryService.new([log1, log2]).call
    entry = result.find { |s| s[:activity_id] == activity.public_id }
    expect(entry[:total_seconds]).to eq(2700)
  end

  it 'ended_atなし・次ログなしはカウントしない' do
    logs = [
      create(:record, user: user, activity: activity,
             logged_at: Time.zone.local(2024, 5, 1, 9, 0), ended_at: nil)
    ]
    expect(WeeklySummaryService.new(logs).call).to eq([])
  end

  it 'ended_atなし・次ログが翌日はカウントしない' do
    activity2 = create(:activity, user: user)
    log1 = create(:record, user: user, activity: activity,
                  logged_at: Time.zone.local(2024, 5, 1, 23, 0), ended_at: nil)
    log2 = create(:record, user: user, activity: activity2,
                  logged_at: Time.zone.local(2024, 5, 2, 1, 0),
                  ended_at:  Time.zone.local(2024, 5, 2, 2, 0))
    result = WeeklySummaryService.new([log1, log2]).call
    expect(result.find { |s| s[:activity_id] == activity.public_id }).to be_nil
  end

  it '43200秒(12時間)を超える場合は43200秒に丸める' do
    logs = [
      create(:record, user: user, activity: activity,
             logged_at: Time.zone.local(2024, 5, 1, 0, 0),
             ended_at:  Time.zone.local(2024, 5, 1, 14, 0))
    ]
    expect(WeeklySummaryService.new(logs).call.first[:total_seconds]).to eq(43200)
  end

  it '同じ行動の複数ログは合算される' do
    t = Time.zone.local(2024, 5, 1, 9, 0)
    create(:record, user: user, activity: activity,
           logged_at: t, ended_at: t + 30.minutes)
    create(:record, user: user, activity: activity,
           logged_at: t + 2.hours, ended_at: t + 2.hours + 30.minutes)
    result = WeeklySummaryService.new(user.records.includes(:activity).to_a).call
    expect(result.first[:total_seconds]).to eq(3600)
    expect(result.first[:count]).to eq(2)
  end

  it '割合が合計に対して正しく計算される' do
    activity2 = create(:activity, user: user)
    t = Time.zone.local(2024, 5, 1, 9, 0)
    create(:record, user: user, activity: activity,
           logged_at: t, ended_at: t + 60.minutes)
    create(:record, user: user, activity: activity2,
           logged_at: t + 60.minutes, ended_at: t + 120.minutes)
    result = WeeklySummaryService.new(user.records.includes(:activity).to_a).call
    expect(result.find { |s| s[:activity_id] == activity.public_id }[:percentage]).to eq(50)
    expect(result.find { |s| s[:activity_id] == activity2.public_id }[:percentage]).to eq(50)
  end

  it '合計時間の多い順にソートされる' do
    activity2 = create(:activity, user: user)
    t = Time.zone.local(2024, 5, 1, 9, 0)
    create(:record, user: user, activity: activity,
           logged_at: t, ended_at: t + 30.minutes)
    create(:record, user: user, activity: activity2,
           logged_at: t + 30.minutes, ended_at: t + 90.minutes)
    result = WeeklySummaryService.new(user.records.includes(:activity).to_a).call
    expect(result.first[:activity_id]).to eq(activity2.public_id)
  end
end
