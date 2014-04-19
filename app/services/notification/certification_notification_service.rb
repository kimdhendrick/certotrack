module Notification
  class CertificationNotificationService
    def initialize(args = {})
      @customer_service = args[:customer_service] || CustomerService.new
      @recipient_service = args[:recipient_service] || RecipientService.new
      @certification_service = args[:certification_service] || CertificationService.new
      @notification_mailer = args[:notification_mailer] || NotificationMailer
    end
    
    def send_expired_notifications(frequency)
      _send_notifications(frequency, :expired)
    end
    
    def send_expiring_notifications(frequency)
      _send_notifications(frequency, :expiring)
    end
    
    private
    
    attr_reader :customer_service, :recipient_service, :certification_service, :notification_mailer
    
    def _send_notifications(frequency, type)
      customer_service.get_customers.each do |customer|
        recipients = recipient_service.get_recipients_for_customer_and_frequency(customer, frequency)
        certifications = _get_certifications(customer, type)
        if certifications.present?
          notification_mailer.certifications(frequency, type, certifications, recipients).deliver
        end
      end
    end
    
    def _get_certifications(customer, type)
      _expired?(type) ?
        certification_service.get_expired_certifications_for_customer(customer) :
        certification_service.get_expiring_certifications_for_customer(customer)
    end
    
    def _expired?(type)
      type == :expired
    end
  end
end