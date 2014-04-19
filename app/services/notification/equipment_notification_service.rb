module Notification
  class EquipmentNotificationService
    def initialize(args = {})
      @customer_service = args[:customer_service] || CustomerService.new
      @recipient_service = args[:recipient_service] || RecipientService.new
      @equipment_service = args[:equipment_service] || EquipmentService.new
      @notification_mailer = args[:notification_mailer] || ::Notification::NotificationMailer
    end

    def send_expired_notifications(frequency)
      _send_notifications(frequency, :expired)
    end

    def send_expiring_notifications(frequency)
      _send_notifications(frequency, :expiring)
    end

    private

    attr_reader :customer_service, :recipient_service, :equipment_service, :notification_mailer

    def _send_notifications(frequency, type)
      customer_service.get_customers.each do |customer|
        recipients = recipient_service.get_recipients_for_customer_and_frequency(customer, frequency)
        equipment = _get_equipment(customer, type)
        if equipment.present?
          notification_mailer.equipment(frequency, type, equipment, recipients).deliver
        end
      end
    end

    def _get_equipment(customer, type)
      _expired?(type) ?
        equipment_service.get_expired_equipment_for_customer(customer) :
        equipment_service.get_expiring_equipment_for_customer(customer)
    end

    def _expired?(type)
      type == :expired
    end
  end
end