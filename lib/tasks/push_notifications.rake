namespace :push_notifications do
  desc "Send push notifications to all subscribers"
  task send: :environment do
    hour = Time.current.in_time_zone("Tokyo").hour
    body = hour < 15 ? "今日の学習を記録しよう！" : "今日の振り返りをしよう！"

    PushSubscription.find_each do |sub|
      begin
        Webpush.payload_send(
          message: JSON.generate({ title: "Study Keeper", body: body }),
          endpoint: sub.endpoint,
          p256dh: sub.p256dh,
          auth: sub.auth,
          vapid: {
            subject: "mailto:#{ENV.fetch('VAPID_CONTACT_EMAIL', 'admin@example.com')}",
            public_key: ENV.fetch("VAPID_PUBLIC_KEY"),
            private_key: ENV.fetch("VAPID_PRIVATE_KEY"),
          }
        )
      rescue => e
        Rails.logger.error "Push failed for subscription #{sub.id}: #{e.message}"
        sub.destroy if e.message.include?("410")
      end
    end
  end
end
