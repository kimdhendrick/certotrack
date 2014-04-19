require 'spec_helper'

module Notification
  describe NotificationMailer do
    describe 'expired_equipment' do
      context 'Daily email' do
        it 'should build email with correct values' do
          equipment = Equipment.new

          recipient_email = 'myemail@example.com'
          recipient = User.new(email: recipient_email)

          expected_args = {
            to: 'myemail@example.com',
            subject: 'Daily Expired Equipment Alert',
            from: 'alerts@certotrack.com'
          }

          ActionMailer::Base.any_instance.should_receive(:mail).with(expected_args)
          NotificationMailer.expired_equipment(:daily, [equipment], [recipient])
        end

        context 'Weekly email' do
          it 'should build email with correct values' do
            equipment = Equipment.new

            recipient_email = 'myemail@example.com'
            recipient = User.new(email: recipient_email)

            expected_args = {
              to: 'myemail@example.com',
              subject: 'Weekly Expired Equipment Alert',
              from: 'alerts@certotrack.com'
            }

            ActionMailer::Base.any_instance.should_receive(:mail).with(expected_args)
            NotificationMailer.expired_equipment(:weekly, [equipment], [recipient])
          end
        end
      end

      it 'should email each recipient' do
        equipment = Equipment.new

        user1 = User.new(email: 'not_empty')
        user2 = User.new(email: 'not_empty')
        ActionMailer::Base.any_instance.should_receive(:mail).twice
        NotificationMailer.expired_equipment(:daily, [equipment], [user1, user2])
      end

      it 'should not email recipients without email addresses' do
        equipment = Equipment.new

        user1 = User.new(email: nil)
        ActionMailer::Base.any_instance.should_not_receive(:mail)

        NotificationMailer.expired_equipment(:daily, [equipment], [user1])
      end

      it 'should build email properly' do
        equipment = create(:equipment, name: 'Box', serial_number: 'SN123', expiration_date: Date.new(2010, 1, 1))

        mail = NotificationMailer.expired_equipment(:daily, [equipment], [User.new(email: 'not_empty')])

        mail.body.should include 'The following pieces of equipment are expired:'
        mail.body.should include 'Equipment'
        mail.body.should include 'Serial Number'
        mail.body.should include 'Assignee'
        mail.body.should include 'Expiration Date'

        mail.body.should include 'Box'
        mail.body.should include 'SN123'
        mail.body.should include 'Unassigned'
        mail.body.should include '01/01/2010'

        mail.body.should include 'From the folks at CertoTrack'
        mail.body.should include "Visit us at: <a href=\"www.certotrack.com\">www.certotrack.com</a>"
      end
    end
  end
end
