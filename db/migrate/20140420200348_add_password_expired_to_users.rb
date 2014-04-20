class AddPasswordExpiredToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_expired, :boolean, default: false
  end
end
