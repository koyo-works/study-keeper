class CreatePushSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :push_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.text :endpoint
      t.string :p256dh
      t.string :auth

      t.timestamps
    end
  end
end
