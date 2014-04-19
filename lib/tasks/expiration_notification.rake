namespace :notification do
  namespace :equipment do
    namespace :daily do
      desc 'Sends daily notifications for expired equipment'
      task :expired => :environment do
        Notification::EquipmentNotificationService.new.send_expired_notifications(:daily)
      end

      desc 'Sends daily notifications for expiring equipment'
      task :expiring => :environment do
        puts 'to do'
      end
    end

    namespace :weekly do
      desc 'Sends weekly notifications for expired equipment'
      task :expired => :environment do
        Notification::EquipmentNotificationService.new.send_expired_notifications(:weekly)
      end

      desc 'Sends weekly notifications for expiring equipment'
      task :expiring => :environment do
        puts 'to do'
      end
    end
  end
end