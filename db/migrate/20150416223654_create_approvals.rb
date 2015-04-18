class CreateApprovals < ActiveRecord::Migration
  def change
    create_table :approvals do |t|
      t.text :trust
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
