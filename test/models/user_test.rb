# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'valid user can be created with factory' do
    user = build(:user)
    assert user.valid?
  end

  test 'name is required' do
    user = build(:user, name: nil)
    assert_not user.valid?
  end

  test 'name cannot exceed 20 characters' do
    user = build(:user, name: 'a' * 21)
    assert_not user.valid?
  end
end
