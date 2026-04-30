# frozen_string_literal: true

require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  test 'valid activity can be created with factory' do
    assert build(:activity).valid?
  end

  test 'activity without user is valid (optional)' do
    assert build(:activity, user: nil).valid?
  end

  test 'active defaults to true' do
    activity = create(:activity)
    assert activity.active
  end

  test 'active can be set to false' do
    activity = create(:activity, active: false)
    assert_not activity.active
  end

  test 'destroying activity destroys associated records' do
    activity = create(:activity)
    create(:record, user: activity.user, activity: activity)
    assert_difference('Record.count', -1) { activity.destroy }
  end
end
