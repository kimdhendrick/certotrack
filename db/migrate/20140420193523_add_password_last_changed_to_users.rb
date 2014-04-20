class AddPasswordLastChangedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_last_changed, :datetime
  end
end
