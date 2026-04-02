class AddGoalToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :goal_activity_id, :integer
    add_column :users, :goal_percentage, :integer, default: 50
  end
end
