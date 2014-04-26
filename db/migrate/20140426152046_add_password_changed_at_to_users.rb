class AddPasswordChangedAtToUsers < ActiveRecord::Migration
  def up
    add_column :users, :password_changed_at, :datetime
    add_index :users, :password_changed_at
  end

  def down
    remove_column :users, :password_changed_at
  end
end
