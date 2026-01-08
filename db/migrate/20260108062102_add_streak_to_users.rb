class AddStreakToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :streak, :integer, default: 0, null: false
  end
end
