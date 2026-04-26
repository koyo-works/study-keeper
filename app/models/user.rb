class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2, :github, :twitter]
  
  has_many :records, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :weekly_goals, dependent: :destroy

  store_accessor :settings, :default_page
  validates :name, presence: true, length: { maximum: 20 }

  def self.from_omniauth(auth)
    user = find_by(provider: auth.provider, uid: auth.uid)
    return user if user

    email = auth.info.email.presence || "#{auth.provider}_#{auth.uid}@example.invalid"

    user = find_by(email: email)
    if user
      user.update(provider: auth.provider, uid: auth.uid)
      return user
    end

    name = (auth.info.name.presence || auth.info.nickname.to_s).slice(0, 20)

    create(
      provider: auth.provider,
      uid: auth.uid,
      email: email,
      name: name,
      password: Devise.friendly_token[0, 20]
    )
  end
end
