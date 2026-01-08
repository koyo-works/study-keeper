class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :records, dependent: :destroy

  def update_streak!
    today = Time.zone.today

    # 今日の記録がなければストリーク更新しない
    return if streak.present? && records.where(created_at: today.all_day).count > 1

    yesterday = today - 1.day

    if records.where(created_at: yesterday.all_day).exists?
      increment!(:streak)
    else
      update!(streak: 1)
    end
  end
end
