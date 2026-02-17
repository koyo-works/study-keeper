class AddPublicIdToActivity < ActiveRecord::Migration[7.1]
  def change
    add_column :activities, :public_id, :uuid, default: "gen_random_uuid()", null: false
    add_index  :activities, :public_id, unique: true
  end
end
