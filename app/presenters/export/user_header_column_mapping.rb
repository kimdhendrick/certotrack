module Export
  module UserHeaderColumnMapping
    HEADERS = 'Username,First Name,Last Name,Email Address,Notification Interval,Customer,Created Date'.split(',')
    COLUMNS = [:username, :first_name, :last_name, :email, :expiration_notification_interval, :customer_name, :created_at]
  end
end