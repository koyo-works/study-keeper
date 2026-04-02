class CreateWeeklyGoals < ActiveRecord::Migration[7.1]
  def change
    create_table :weekly_goals do |t|
      t.integer :user_id, null: false
      t.integer :activity_id, null: false
      t.integer :percentage, null: false, default: 50
      t.date :week_start, null: false

      t.timestamps
    end

    add_index :weekly_goals, [:user_id, :week_start], unique: true
  end
end