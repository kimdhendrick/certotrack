module Notification
  class RecipientService
    def get_recipients_for_customer_and_frequency(customer, frequency)
      User.where(customer: customer, expiration_notification_interval: frequency.to_s.capitalize)
    end
  end
end