# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activity, type: :model do
  it 'ファクトリで有効なアクティビティを作成できる' do
    expect(build(:activity)).to be_valid
  end

  it 'userなしでも有効' do
    expect(build(:activity, user: nil)).to be_valid
  end

  it 'activeはデフォルトでtrue' do
    expect(create(:activity).active).to be true
  end

  it 'activeをfalseにできる' do
    expect(create(:activity, active: false).active).to be false
  end

  it 'アクティビティ削除時にrecordsも削除される' do
    activity = create(:activity)
    create(:record, user: activity.user, activity: activity)
    expect { activity.destroy }.to change(Record, :count).by(-1)
  end
end
