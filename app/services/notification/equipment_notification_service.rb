module Notification
  class EquipmentNotificationService
    def initialize(args = {})
      @customer_service = args[:customer_service] || CustomerService.new
      @recipient_service = args[:recipient_service] || RecipientService.new
      @equipment_service = args[:equipment_service] || EquipmentService.new
      @notification_mailer = args[:notification_mailer] || ::Notification::NotificationMailer
    end

    def send_expired_notifications(frequency)
      customer_service.get_customers.each do |customer|
        recipients = recipient_service.get_recipients_for_customer_and_frequency(customer, frequency)
        equipment = equipment_service.get_expired_equipment_for_customer(customer)

        if equipment.present?
          notification_mailer.expired_equipment(frequency, equipment, recipients).deliver
        end
      end
    end

    private

    attr_reader :customer_service, :recipient_service, :equipment_service, :notification_mailer
  end
end