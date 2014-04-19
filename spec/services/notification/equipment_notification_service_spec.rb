require 'spec_helper'

module Notification
  describe EquipmentNotificationService do
    let(:customer) { create(:customer) }
    let(:customer_service) { double(get_customers: []) }
    let(:customer_service_with_customer) { double(get_customers: [customer]) }
    let(:recipient_service) { double(get_recipients_for_customer_and_frequency: []) }
    let(:equipment_service) { double(get_expired_equipment_for_customer: []) }
    let(:mailable) { double(deliver: nil)}
    let(:notification_mailer) { double(expired_equipment: mailable, deliver: nil) }
    let(:params) do
      {
        customer_service: customer_service,
        recipient_service: recipient_service,
        equipment_service: equipment_service,
        notification_mailer: notification_mailer
      }
    end

    it 'should get customers' do
      customer_service.should_receive(:get_customers)

      equipment_notification_service = EquipmentNotificationService.new(params)
      equipment_notification_service.send_expired_notifications(:daily)
    end

    it 'should get daily recipients' do
      recipient_service.should_receive(:get_recipients_for_customer_and_frequency).with(customer, :daily)

      equipment_notification_service = EquipmentNotificationService.new(params.merge(customer_service: customer_service_with_customer))
      equipment_notification_service.send_expired_notifications(:daily)
    end

    it 'should get weekly recipients' do
      recipient_service.should_receive(:get_recipients_for_customer_and_frequency).with(customer, :weekly)

      equipment_notification_service = EquipmentNotificationService.new(params.merge(customer_service: customer_service_with_customer))
      equipment_notification_service.send_expired_notifications(:weekly)
    end

    it 'should get expired equipment' do
      equipment_service.should_receive(:get_expired_equipment_for_customer).with(customer)

      equipment_notification_service = EquipmentNotificationService.new(params.merge(customer_service: customer_service_with_customer))
      equipment_notification_service.send_expired_notifications(:daily)
    end

    it 'should handle no expired equipment for customer' do
      expired_equipment = []
      equipment_service = double(get_expired_equipment_for_customer: expired_equipment)
      NotificationMailer.should_not_receive(:expired_equipment)

      equipment_notification_service = EquipmentNotificationService.new(
        customer_service: customer_service_with_customer,
        equipment_service: equipment_service
      )
      equipment_notification_service.send_expired_notifications(:daily)
    end

    it 'should get deliver notifications' do
      expired_equipment = [double]
      recipients = double
      equipment_service = double(get_expired_equipment_for_customer: expired_equipment)
      recipient_service = double(get_recipients_for_customer_and_frequency: recipients)

      mailable.should_receive(:deliver)
      NotificationMailer.should_receive(:expired_equipment).with(:daily, expired_equipment, recipients).and_return(mailable)

      equipment_notification_service = EquipmentNotificationService.new(
        customer_service: customer_service_with_customer,
        equipment_service: equipment_service,
        recipient_service: recipient_service
      )
      equipment_notification_service.send_expired_notifications(:daily)
    end
  end
end