require 'spec_helper'
require 'rake'

describe 'notifications' do
  before :all do
    load File.expand_path('../../../../Rakefile', __FILE__)
  end

  before do
    task.reenable
  end

  describe 'notification:equipment:expired' do
    let(:task) { Rake::Task['notification:equipment:expired'] }

    it 'should send expired equipment notifications' do
      equipment_notification_service = double('EquipmentNotificationService')
      Notification::EquipmentNotificationService.stub(:new).and_return(equipment_notification_service)
      equipment_notification_service.should_receive(:send_expired_notifications).with(:daily)

      task.invoke
    end
  end
end