class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :name
      t.integer :owner_id
      t.timestamps
    end
    add_index :accounts, :owner_id
  end

  def self.down
    drop_table :accounts
  end
end
