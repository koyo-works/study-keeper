class Record < ApplicationRecord
  belongs_to :user
  belongs_to :activity

  validates :activity_id, presence: true

  def to_param
    public_id
  end
end
