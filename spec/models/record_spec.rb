# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Record, type: :model do
  let(:user)     { create(:user) }
  let(:activity) { create(:activity, user: user) }

  it 'ファクトリで有効なレコードを作成できる' do
    expect(create(:record, user: user, activity: activity)).to be_valid
  end

  it 'activity_idは必須' do
    expect(build(:record, user: user, activity: nil)).not_to be_valid
  end

  it 'userは必須' do
    expect(build(:record, user: nil, activity: activity)).not_to be_valid
  end

  it 'logged_atが空の場合は自動セットされる' do
    record = create(:record, user: user, activity: activity, logged_at: nil)
    expect(record.logged_at).not_to be_nil
  end

  it 'logged_atが設定済みの場合は上書きされない' do
    time   = 3.days.ago
    record = create(:record, user: user, activity: activity, logged_at: time)
    expect(record.logged_at).to be_within(1.second).of(time)
  end

  it 'to_paramはpublic_idを返す' do
    record = create(:record, user: user, activity: activity)
    expect(record.to_param).to eq(record.public_id.to_s)
  end

  describe '.in_week' do
    it '当週のレコードを返す' do
      today     = Date.current
      this_week = create(:record, user: user, activity: activity, logged_at: today.beginning_of_week(:monday))
      last_week = create(:record, user: user, activity: activity, logged_at: today.beginning_of_week(:monday) - 1.week)
      results   = Record.in_week(today)
      expect(results).to include(this_week)
      expect(results).not_to include(last_week)
    end
  end
end
