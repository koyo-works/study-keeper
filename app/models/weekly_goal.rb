class WeeklyGoal < ApplicationRecord
  belongs_to :user
  belongs_to :activity

  validates :week_start, uniqueness: { scope: :user_id }
end