class DropColumnNotificationFromCustomers < ActiveRecord::Migration
  def change
    remove_column :customers, :notification, :boolean
  end
end
