# frozen_string_literal: true

require 'test_helper'
require 'ostruct'

class UserTest < ActiveSupport::TestCase
  # --- バリデーション ---
  test 'valid user can be created with factory' do
    assert build(:user).valid?
  end

  test 'name is required' do
    assert_not build(:user, name: nil).valid?
  end

  test 'name cannot exceed 20 characters' do
    assert_not build(:user, name: 'a' * 21).valid?
  end

  test 'name of exactly 20 characters is valid' do
    assert build(:user, name: 'a' * 20).valid?
  end

  test 'email is required' do
    assert_not build(:user, email: nil).valid?
  end

  test 'email must be unique' do
    existing = create(:user)
    assert_not build(:user, email: existing.email).valid?
  end

  # --- アソシエーション ---
  test 'destroying user destroys associated records' do
    user     = create(:user)
    activity = create(:activity, user: user)
    create(:record, user: user, activity: activity)
    assert_difference('Record.count', -1) { user.destroy }
  end

  test 'destroying user destroys associated activities' do
    user = create(:user)
    create(:activity, user: user)
    assert_difference('Activity.count', -1) { user.destroy }
  end

  # --- from_omniauth ---
  test 'from_omniauth returns existing user by provider and uid' do
    user = create(:user, provider: 'github', uid: '12345')
    auth = mock_auth('github', '12345', user.email)
    assert_equal user, User.from_omniauth(auth)
  end

  test 'from_omniauth links existing email account' do
    user = create(:user, provider: nil, uid: nil)
    auth = mock_auth('github', '99999', user.email)
    result = User.from_omniauth(auth)
    assert_equal user.id, result.id
    assert_equal 'github', result.provider
  end

  test 'from_omniauth creates new user when not found' do
    auth = mock_auth('github', 'new123', 'new@example.com')
    assert_difference('User.count', 1) { User.from_omniauth(auth) }
  end

  private

  def mock_auth(provider, uid, email, name = 'Test User')
    OpenStruct.new(
      provider: provider,
      uid: uid,
      info: OpenStruct.new(email: email, name: name, nickname: nil)
    )
  end
end
