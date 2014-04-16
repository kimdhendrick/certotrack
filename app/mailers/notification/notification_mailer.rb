module Notification
  class NotificationMailer < ActionMailer::Base
    def expired_equipment(equipment, recipients)
      _with_emails(recipients).each do |recipient|
        @equipment = EquipmentListPresenter.new(equipment).sort
        mail(to: recipient.email, subject: _subject('Daily'), from: _sender)
      end
    end

    private

    def _with_emails(recipients)
      recipients.select { |it| it.email.present? }
    end

    def _subject(type)
      "#{type} Expired Equipment Alert"
    end

    def _sender
      'alerts@certotrack.com'
    end
  end
end
