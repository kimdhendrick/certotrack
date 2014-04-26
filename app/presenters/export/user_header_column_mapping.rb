module Export
  module UserHeaderColumnMapping
    HEADERS = 'Username,First Name,Last Name,Email Address,Password Last Changed,Notification Interval,Customer,Created Date'.split(',')
    COLUMNS = [:username, :first_name, :last_name, :email, :password_changed_at, :expiration_notification_interval, :customer_name, :created_at]
  end
end