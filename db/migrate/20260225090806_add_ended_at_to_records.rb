class AddEndedAtToRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :records, :ended_at, :datetime
  end
end
