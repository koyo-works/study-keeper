class RemoveGoalColumnsFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :goal_activity_id, :integer
    remove_column :users, :goal_percentage, :integer
  end
end
