module Notification
  class NotificationMailer < ActionMailer::Base
    def equipment(frequency, type, equipment, recipients)
      _with_emails(recipients).each do |recipient|
        @equipment = EquipmentListPresenter.new(equipment).sort
        @message = type == :expired ? 'expired' : 'coming due'
        mail(to: recipient.email, subject: _subject(frequency, type, 'Equipment'), from: _sender)
      end
    end

    def certifications(frequency, type, certifications, recipients)
      _with_emails(recipients).each do |recipient|
        @certifications = CertificationListPresenter.new(certifications).sort
        @message = type == :expired ? 'expired' : 'coming due'
        mail(to: recipient.email, subject: _subject(frequency, type, 'Certification'), from: _sender)
      end
    end

    private

    def _with_emails(recipients)
      recipients.select { |it| it.email.present? }
    end

    def _subject(frequency, type, resource_type)
      "#{frequency.to_s.capitalize} #{type == :expired ? 'Expired' : 'Coming Due'} #{resource_type} Alert"
    end

    def _sender
      'alerts@certotrack.com'
    end
  end
end
