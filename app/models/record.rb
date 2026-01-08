class Record < ApplicationRecord
  belongs_to :user
  belongs_to :activity

  validates :activity_id, presence: true

  after_commit :update_user_streak, on: :create

  private

  def update_user_streak
    user.update_streak!
  end
end
