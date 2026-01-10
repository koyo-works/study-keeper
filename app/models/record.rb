class Record < ApplicationRecord
  belongs_to :user
  belongs_to :activity

  validates :activity_id, presence: true

end
