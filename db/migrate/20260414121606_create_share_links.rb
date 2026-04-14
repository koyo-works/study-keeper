class CreateShareLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :share_links do |t|
      t.string :token, null: false
      t.references :user, null: false, foreign_key: true
      t.string :share_type, null: false
      t.date :target_date, null: false
      t.timestamps
    end
    add_index :share_links, :token, unique: true
  end
end
