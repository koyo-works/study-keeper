# frozen_string_literal: true

require 'rails_helper'
require 'ostruct'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    it 'ファクトリで有効なユーザーを作成できる' do
      expect(build(:user)).to be_valid
    end

    it 'nameは必須' do
      expect(build(:user, name: nil)).not_to be_valid
    end

    it 'nameは20文字以下' do
      expect(build(:user, name: 'a' * 21)).not_to be_valid
    end

    it 'nameが20文字は有効' do
      expect(build(:user, name: 'a' * 20)).to be_valid
    end

    it 'emailは必須' do
      expect(build(:user, email: nil)).not_to be_valid
    end

    it 'emailは一意' do
      existing = create(:user)
      expect(build(:user, email: existing.email)).not_to be_valid
    end
  end

  describe 'アソシエーション' do
    it 'ユーザー削除時にrecordsも削除される' do
      user     = create(:user)
      activity = create(:activity, user: user)
      create(:record, user: user, activity: activity)
      expect { user.destroy }.to change(Record, :count).by(-1)
    end

    it 'ユーザー削除時にactivitiesも削除される' do
      user = create(:user)
      create(:activity, user: user)
      expect { user.destroy }.to change(Activity, :count).by(-1)
    end
  end

  describe '.from_omniauth' do
    it 'provider/uidが一致する既存ユーザーを返す' do
      user = create(:user, provider: 'github', uid: '12345')
      auth = mock_auth('github', '12345', user.email)
      expect(User.from_omniauth(auth)).to eq(user)
    end

    it '既存のメールアカウントにprovider/uidを紐付ける' do
      user = create(:user, provider: nil, uid: nil)
      auth = mock_auth('github', '99999', user.email)
      result = User.from_omniauth(auth)
      expect(result.id).to eq(user.id)
      expect(result.provider).to eq('github')
    end

    it '見つからない場合は新規ユーザーを作成する' do
      auth = mock_auth('github', 'new123', 'new@example.com')
      expect { User.from_omniauth(auth) }.to change(User, :count).by(1)
    end

    it 'メールがない場合はフォールバックメールを生成する' do
      auth = mock_auth('twitter', 'tw999', nil, 'twitteruser')
      user = User.from_omniauth(auth)
      expect(user).to be_persisted
      expect(user.email).to match(/twitter_tw999@example\.invalid/)
    end

    it 'nameが空の場合はnicknameをnameとして使う' do
      auth = OpenStruct.new(
        provider: 'github',
        uid: 'gh001',
        info: OpenStruct.new(email: nil, name: nil, nickname: 'octocat')
      )
      user = User.from_omniauth(auth)
      expect(user.name).to eq('octocat')
    end

    it 'nameが20文字を超える場合は切り捨てる' do
      auth = mock_auth('google_oauth2', 'g001', 'long@example.com', 'a' * 30)
      user = User.from_omniauth(auth)
      expect(user).to be_persisted
      expect(user.name.length).to be <= 20
    end
  end

  def mock_auth(provider, uid, email, name = 'Test User')
    OpenStruct.new(
      provider: provider,
      uid: uid,
      info: OpenStruct.new(email: email, name: name, nickname: nil)
    )
  end
end
