class AddIdentityUrlToLegacyUsers < ActiveRecord::Migration
  def change
    add_column :legacy_users, :identity_url, :string
  end
end
