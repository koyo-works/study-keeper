class ShareLink < ApplicationRecord
  belongs_to :user

  enum share_type: { daily: 'daily' }

  before_create :generate_token

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(16)
  end
end