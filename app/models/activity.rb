class Activity < ApplicationRecord
  has_many :records, dependent: :destroy
end
