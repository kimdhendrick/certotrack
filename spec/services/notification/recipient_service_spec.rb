require 'spec_helper'

module Notification
  describe RecipientService do
    describe 'get_recipients_for_customer_and_frequency' do
      let!(:my_customer) { create(:customer, name: 'A Customer') }
      let!(:another_customer) { create(:customer, name: 'Another Customer') }
      let(:recipient_service) { RecipientService.new }

      context 'daily' do
        it 'should return all recipients for customer' do
          my_recipient = create(:user, customer: my_customer, expiration_notification_interval: 'Daily')
          another_customer_recipient = create(:user, customer: another_customer, expiration_notification_interval: 'Daily')

          recipient_service.get_recipients_for_customer_and_frequency(my_customer, :daily).should == [my_recipient]
        end

        it 'should return all recipients for with daily notifications' do
          my_daily_recipient = create(:user, customer: my_customer, expiration_notification_interval: 'Daily')
          my_weekly_recipient = create(:user, customer: my_customer, expiration_notification_interval: 'Weekly')

          recipient_service.get_recipients_for_customer_and_frequency(my_customer, :daily).should == [my_daily_recipient]
        end
      end
    end
  end
end