class Record < ApplicationRecord
  belongs_to :user
  belongs_to :activity

  validates :activity_id, presence: true
  before_create :set_logged_at

  scope :in_week, ->(date) {
    start_date = date.beginning_of_week(:monday)
    end_date   = date.end_of_week(:monday)
    where(logged_at: start_date.beginning_of_day..end_date.end_of_day)
  }

  def to_param
    public_id
  end

  private

  def set_logged_at
    self.logged_at ||= Time.current
  end
end
