class AddForcePasswordResetToUsers < ActiveRecord::Migration
  def change
    add_column :users, :force_password_reset, :boolean
  end
end
