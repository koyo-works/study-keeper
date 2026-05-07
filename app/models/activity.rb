class Activity < ApplicationRecord
  belongs_to :user, optional: true
  has_many :records, dependent: :destroy

  validates :name, presence: true
end
