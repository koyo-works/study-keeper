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
    user = find_by(provider: auth.provider, uid: auth.uid)
    return user if user

    user = find_by(email: auth.info.email)
    if user
      user.update(provider: auth.provider, uid: auth.uid)
      return user
    end

    create(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email,
      name: auth.info.name.to_s.slice(0, 20),
      password: Devise.friendly_token[0, 20]
    )
  end
end
