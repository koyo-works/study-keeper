# frozen_string_literal: true

require 'test_helper'

class WeeklyGoalTest < ActiveSupport::TestCase
  test 'valid weekly_goal can be created with factory' do
    assert build(:weekly_goal).valid?
  end

  test 'user is required' do
    assert_not build(:weekly_goal, user: nil).valid?
  end

  test 'activity is required' do
    assert_not build(:weekly_goal, activity: nil).valid?
  end

  test 'percentage defaults to 50' do
    goal = create(:weekly_goal)
    assert_equal 50, goal.percentage
  end

  test 'week_start must be unique per user' do
    goal = create(:weekly_goal)
    duplicate = build(:weekly_goal, user: goal.user, week_start: goal.week_start)
    assert_not duplicate.valid?
  end
end
