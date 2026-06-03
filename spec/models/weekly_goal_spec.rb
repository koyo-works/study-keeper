# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeeklyGoal, type: :model do
  it 'ファクトリで有効なweekly_goalを作成できる' do
    expect(build(:weekly_goal)).to be_valid
  end

  it 'userは必須' do
    expect(build(:weekly_goal, user: nil)).not_to be_valid
  end

  it 'activityは必須' do
    expect(build(:weekly_goal, activity: nil)).not_to be_valid
  end

  it 'percentageのデフォルトは50' do
    expect(create(:weekly_goal).percentage).to eq(50)
  end

  it 'week_startはユーザーごとに一意' do
    goal      = create(:weekly_goal)
    duplicate = build(:weekly_goal, user: goal.user, week_start: goal.week_start)
    expect(duplicate).not_to be_valid
  end
end
