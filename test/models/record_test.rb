# frozen_string_literal: true

require 'test_helper'

class RecordTest < ActiveSupport::TestCase
  setup do
    @user     = create(:user)
    @activity = create(:activity, user: @user)
  end

  test 'valid record can be created with factory' do
    assert create(:record, user: @user, activity: @activity).valid?
  end

  test 'activity_id is required' do
    assert_not build(:record, user: @user, activity: nil).valid?
  end

  test 'user is required' do
    assert_not build(:record, user: nil, activity: @activity).valid?
  end

  test 'logged_at is set automatically if blank' do
    record = create(:record, user: @user, activity: @activity, logged_at: nil)
    assert_not_nil record.logged_at
  end

  test 'logged_at is not overwritten if already set' do
    time   = 3.days.ago
    record = create(:record, user: @user, activity: @activity, logged_at: time)
    assert_in_delta time, record.logged_at, 1.second
  end

  test 'to_param returns public_id' do
    record = create(:record, user: @user, activity: @activity)
    assert_equal record.public_id.to_s, record.to_param
  end

  test 'in_week scope returns records within the week' do
    today     = Date.current
    this_week = create(:record, user: @user, activity: @activity, logged_at: today.beginning_of_week(:monday))
    last_week = create(:record, user: @user, activity: @activity, logged_at: today.beginning_of_week(:monday) - 1.week)
    results   = Record.in_week(today)
    assert_includes results, this_week
    assert_not_includes results, last_week
  end
end
