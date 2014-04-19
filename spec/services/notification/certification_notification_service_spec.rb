require 'spec_helper'

module Notification
  describe CertificationNotificationService do
    let(:customer) { create(:customer) }
    let(:customer_service) { double(get_customers: []) }
    let(:customer_service_with_customer) { double(get_customers: [customer]) }
    let(:recipient_service) { double(get_recipients_for_customer_and_frequency: []) }
    let(:certification_service) { double(get_expired_certifications_for_customer: [], get_expiring_certifications_for_customer: []) }
    let(:mailable) { double(deliver: nil) }
    let(:notification_mailer) { double(certifications: mailable, deliver: nil) }
    let(:params) do
      {
        customer_service: customer_service,
        recipient_service: recipient_service,
        certification_service: certification_service,
        notification_mailer: notification_mailer
      }
    end

    it 'should get customers' do
      customer_service.should_receive(:get_customers)

      certification_notification_service = CertificationNotificationService.new(params)
      certification_notification_service.send_expired_notifications(:daily)
    end

    it 'should get daily recipients' do
      recipient_service.should_receive(:get_recipients_for_customer_and_frequency).with(customer, :daily)

      certification_notification_service = CertificationNotificationService.new(params.merge(customer_service: customer_service_with_customer))
      certification_notification_service.send_expired_notifications(:daily)
    end

    it 'should get weekly recipients' do
      recipient_service.should_receive(:get_recipients_for_customer_and_frequency).with(customer, :weekly)

      certification_notification_service = CertificationNotificationService.new(params.merge(customer_service: customer_service_with_customer))
      certification_notification_service.send_expired_notifications(:weekly)
    end

    context 'expired certifications' do
      it 'should get expired certifications' do
        certification_service.should_receive(:get_expired_certifications_for_customer).with(customer)

        certification_notification_service = CertificationNotificationService.new(params.merge(customer_service: customer_service_with_customer))
        certification_notification_service.send_expired_notifications(:daily)
      end

      it 'should handle no expired certifications for customer' do
        expired_certification = []
        certification_service = double(get_expired_certifications_for_customer: expired_certification)
        NotificationMailer.should_not_receive(:certification)

        certification_notification_service = CertificationNotificationService.new(
          customer_service: customer_service_with_customer,
          certification_service: certification_service
        )
        certification_notification_service.send_expired_notifications(:daily)
      end

      it 'should get deliver notifications' do
        expired_certification = [double]
        recipients = double
        certification_service = double(get_expired_certifications_for_customer: expired_certification)
        recipient_service = double(get_recipients_for_customer_and_frequency: recipients)

        mailable.should_receive(:deliver)
        NotificationMailer.should_receive(:certifications).with(:daily, :expired, expired_certification, recipients).and_return(mailable)

        certification_notification_service = CertificationNotificationService.new(
          customer_service: customer_service_with_customer,
          certification_service: certification_service,
          recipient_service: recipient_service
        )
        certification_notification_service.send_expired_notifications(:daily)
      end
    end

    context 'expiring certifications' do
      it 'should get expiring certifications' do
        certification_service.should_receive(:get_expiring_certifications_for_customer).with(customer)

        certification_notification_service = CertificationNotificationService.new(params.merge(customer_service: customer_service_with_customer))
        certification_notification_service.send_expiring_notifications(:daily)
      end

      it 'should handle no expiring certifications for customer' do
        expiring_certification = []
        certification_service = double(get_expiring_certifications_for_customer: expiring_certification)
        NotificationMailer.should_not_receive(:expiring_certification)

        certification_notification_service = CertificationNotificationService.new(
          customer_service: customer_service_with_customer,
          certification_service: certification_service
        )
        certification_notification_service.send_expiring_notifications(:daily)
      end

      it 'should get deliver notifications' do
        expiring_certification = [double]
        recipients = double
        certification_service = double(get_expiring_certifications_for_customer: expiring_certification)
        recipient_service = double(get_recipients_for_customer_and_frequency: recipients)

        mailable.should_receive(:deliver)
        NotificationMailer.should_receive(:certifications).with(:daily, :expiring, expiring_certification, recipients).and_return(mailable)

        certification_notification_service = CertificationNotificationService.new(
          customer_service: customer_service_with_customer,
          certification_service: certification_service,
          recipient_service: recipient_service
        )
        certification_notification_service.send_expiring_notifications(:daily)
      end
    end
  end
end