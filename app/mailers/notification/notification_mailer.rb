module Notification
  class NotificationMailer < ActionMailer::Base
    def expired_equipment(frequency, equipment, recipients)
      _with_emails(recipients).each do |recipient|
        @equipment = EquipmentListPresenter.new(equipment).sort
        mail(to: recipient.email, subject: _subject(frequency), from: _sender)
      end
    end

    private

    def _with_emails(recipients)
      recipients.select { |it| it.email.present? }
    end

    def _subject(type)
      "#{type.to_s.capitalize} Expired Equipment Alert"
    end

    def _sender
      'alerts@certotrack.com'
    end
  end
end
