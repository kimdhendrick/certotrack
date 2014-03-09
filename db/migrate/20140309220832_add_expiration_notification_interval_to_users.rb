class AddExpirationNotificationIntervalToUsers < ActiveRecord::Migration
  def change
    add_column :users, :expiration_notification_interval, :string, default: 'Never'
  end
end
