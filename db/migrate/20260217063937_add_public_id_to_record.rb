class AddPublicIdToRecord < ActiveRecord::Migration[7.1]
  def change
    add_column :records, :public_id, :uuid, default: "gen_random_uuid()",null: false
    add_index  :records, :public_id, unique: true
    #Ex:- add_index("admin_users", "username")
  end
end
