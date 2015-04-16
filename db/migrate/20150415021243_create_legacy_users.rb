class CreateLegacyUsers < ActiveRecord::Migration
  def change
    create_table :legacy_users do |t|
      t.string :login
      t.string :email
      t.string :crypted_password
      t.string :salt
      t.string :first_name
      t.string :last_name
      t.boolean :active

      t.timestamps null: false
    end
  end
end
