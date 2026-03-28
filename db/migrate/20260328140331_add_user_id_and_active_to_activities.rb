class AddUserIdAndActiveToActivities < ActiveRecord::Migration[7.1]
  def change
    add_column :activities, :user_id, :integer
    add_column :activities, :active, :boolean, default: true, null: false
    add_index :activities, :user_id
  end
end
