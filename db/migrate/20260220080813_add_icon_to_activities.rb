class AddIconToActivities < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:activities, :icon)
      add_column :activities, :icon, :string
    end
  end
end
