class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]
  
  has_many :records, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :weekly_goals, dependent: :destroy

  store_accessor :settings, :default_page
  validates :name, presence: true, length: { maximum: 20 }

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.email    = auth.info.email
      user.name     = auth.info.name.to_s.slice(0, 20)
      user.password = Devise.friendly_token[0, 20]
    end
  end
end
