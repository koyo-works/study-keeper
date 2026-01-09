class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :records, dependent: :destroy

  validates :name, presence: true, length: { maximum: 20 }

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

  def reset_streak_if_needed!
    yesterday = Time.zone.yesterday
    today = Time.zone.today

    if records.where(created_at: yesterday.all_day).exists?
      # 昨日 Record がある → streak 継続の可能性、何もしない
      return
    end

    if records.where(created_at: today.all_day).exists?
      # 今日 Record がある → streak は途切れて今日から 1
      update!(streak: 1)
    else
      # 今日 Record がない → streak は 0 にリセット
      update!(streak: 0)
    end
  end
end
