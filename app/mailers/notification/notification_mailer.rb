module Notification
  class NotificationMailer < ActionMailer::Base
    def equipment(frequency, type, equipment, recipients)
      _with_emails(recipients).each do |recipient|
        @equipment = EquipmentListPresenter.new(equipment).sort
        @message = type == :expired ? 'expired' : 'coming due'
        mail(to: recipient.email, subject: _subject(frequency, type), from: _sender)
      end
    end

    private

    def _with_emails(recipients)
      recipients.select { |it| it.email.present? }
    end

    def _subject(frequency, type)
      "#{frequency.to_s.capitalize} #{type == :expired ? 'Expired' : 'Coming Due'} Equipment Alert"
    end

    def _sender
      'alerts@certotrack.com'
    end
  end
end
