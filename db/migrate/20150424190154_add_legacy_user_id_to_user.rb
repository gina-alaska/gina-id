class AddLegacyUserIdToUser < ActiveRecord::Migration
  def change
    add_reference :users, :legacy_user, index: true, foreign_key: true
  end
end
