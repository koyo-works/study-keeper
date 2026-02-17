class AddLoggedAtToRecord < ActiveRecord::Migration[7.1]
  def change
    add_column :records, :logged_at, :datetime
  end
end
