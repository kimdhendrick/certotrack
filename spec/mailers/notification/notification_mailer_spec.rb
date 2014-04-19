require 'spec_helper'

module Notification
  describe NotificationMailer do
    describe 'equipment' do
      context 'Daily email' do
        context 'expired' do
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
            NotificationMailer.equipment(:daily, :expired, [equipment], [recipient])
          end
        end

        context 'expiring' do
          it 'should build email with correct values' do
            equipment = Equipment.new

            recipient_email = 'myemail@example.com'
            recipient = User.new(email: recipient_email)

            expected_args = {
              to: 'myemail@example.com',
              subject: 'Daily Coming Due Equipment Alert',
              from: 'alerts@certotrack.com'
            }

            ActionMailer::Base.any_instance.should_receive(:mail).with(expected_args)
            NotificationMailer.equipment(:daily, :expiring, [equipment], [recipient])
          end
        end

        context 'Weekly email' do
          context 'expired' do
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
              NotificationMailer.equipment(:weekly, :expired, [equipment], [recipient])
            end
          end

          context 'expiring' do
            it 'should build email with correct values' do
              equipment = Equipment.new

              recipient_email = 'myemail@example.com'
              recipient = User.new(email: recipient_email)

              expected_args = {
                to: 'myemail@example.com',
                subject: 'Weekly Coming Due Equipment Alert',
                from: 'alerts@certotrack.com'
              }

              ActionMailer::Base.any_instance.should_receive(:mail).with(expected_args)
              NotificationMailer.equipment(:weekly, :expiring, [equipment], [recipient])
            end
          end
        end
      end

      context 'expired' do
        it 'should email each recipient' do
          equipment = Equipment.new

          user1 = User.new(email: 'not_empty')
          user2 = User.new(email: 'not_empty')
          ActionMailer::Base.any_instance.should_receive(:mail).twice
          NotificationMailer.equipment(:daily, :expired, [equipment], [user1, user2])
        end

        it 'should not email recipients without email addresses' do
          equipment = Equipment.new

          user1 = User.new(email: nil)
          ActionMailer::Base.any_instance.should_not_receive(:mail)

          NotificationMailer.equipment(:daily, :expired, [equipment], [user1])
        end

        it 'should build email properly' do
          equipment = create(:equipment, name: 'Box', serial_number: 'SN123', expiration_date: Date.new(2010, 1, 1))

          mail = NotificationMailer.equipment(:daily, :expired, [equipment], [User.new(email: 'not_empty')])

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

      context 'expiring' do
        it 'should email each recipient' do
          equipment = Equipment.new

          user1 = User.new(email: 'not_empty')
          user2 = User.new(email: 'not_empty')
          ActionMailer::Base.any_instance.should_receive(:mail).twice
          NotificationMailer.equipment(:daily, :expiring, [equipment], [user1, user2])
        end

        it 'should not email recipients without email addresses' do
          equipment = Equipment.new

          user1 = User.new(email: nil)
          ActionMailer::Base.any_instance.should_not_receive(:mail)

          NotificationMailer.equipment(:daily, :expiring, [equipment], [user1])
        end

        it 'should build email properly' do
          equipment = create(:equipment, name: 'Box', serial_number: 'SN123', expiration_date: Date.tomorrow)

          mail = NotificationMailer.equipment(:daily, :expiring, [equipment], [User.new(email: 'not_empty')])

          mail.body.should include 'The following pieces of equipment are coming due:'
          mail.body.should include 'Equipment'
          mail.body.should include 'Serial Number'
          mail.body.should include 'Assignee'
          mail.body.should include 'Expiration Date'

          mail.body.should include 'Box'
          mail.body.should include 'SN123'
          mail.body.should include 'Unassigned'
          mail.body.should include "#{Date.tomorrow.strftime('%m/%d/%Y')}"

          mail.body.should include 'From the folks at CertoTrack'
          mail.body.should include "Visit us at: <a href=\"www.certotrack.com\">www.certotrack.com</a>"
        end
      end
    end
  end
end
