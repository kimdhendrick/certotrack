require 'spec_helper'
require 'rake'

describe 'notifications' do
  before :all do
    load File.expand_path('../../../../Rakefile', __FILE__)
  end

  before do
    task.reenable
  end

  describe 'notification:equipment:daily:expired' do
    let(:task) { Rake::Task['notification:equipment:daily:expired'] }

    it 'should send daily expired equipment notifications' do
      equipment_notification_service = double('EquipmentNotificationService')
      Notification::EquipmentNotificationService.stub(:new).and_return(equipment_notification_service)
      equipment_notification_service.should_receive(:send_expired_notifications).with(:daily)

      task.invoke
    end
  end

  describe 'notification:equipment:weekly:expired' do
    let(:task) { Rake::Task['notification:equipment:weekly:expired'] }

    it 'should send weekly expired equipment notifications' do
      equipment_notification_service = double('EquipmentNotificationService')
      Notification::EquipmentNotificationService.stub(:new).and_return(equipment_notification_service)
      equipment_notification_service.should_receive(:send_expired_notifications).with(:weekly)

      task.invoke
    end
  end
end