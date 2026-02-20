class Record < ApplicationRecord
  belongs_to :user
  belongs_to :activity

  validates :activity_id, presence: true
  before_create :set_logged_at

  def to_param
    public_id
  end

  private

  def set_logged_at
    self.logged_at ||= Time.current
  end
end
