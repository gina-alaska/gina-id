class CreateOidRequests < ActiveRecord::Migration
  def change
    create_table :oid_requests do |t|
      t.text :request

      t.timestamps null: false
    end
  end
end
