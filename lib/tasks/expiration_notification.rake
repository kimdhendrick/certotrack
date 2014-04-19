namespace :notification do
  namespace :equipment do
    namespace :daily do
      desc 'Sends daily notifications for expired equipment'
      task :expired => :environment do
        Notification::EquipmentNotificationService.new.send_expired_notifications(:daily)
      end

      desc 'Sends daily notifications for expiring equipment'
      task :expiring => :environment do
        Notification::EquipmentNotificationService.new.send_expiring_notifications(:daily)
      end
    end

    namespace :weekly do
      desc 'Sends weekly notifications for expired equipment'
      task :expired => :environment do
        Notification::EquipmentNotificationService.new.send_expired_notifications(:weekly)
      end

      desc 'Sends weekly notifications for expiring equipment'
      task :expiring => :environment do
        Notification::EquipmentNotificationService.new.send_expiring_notifications(:weekly)
      end
    end
  end

  namespace :certification do
    namespace :daily do
      desc 'Sends daily notifications for expired certification'
      task :expired => :environment do
        Notification::CertificationNotificationService.new.send_expired_notifications(:daily)
      end

      desc 'Sends daily notifications for expiring certification'
      task :expiring => :environment do
        Notification::CertificationNotificationService.new.send_expiring_notifications(:daily)
      end
    end

    namespace :weekly do
      desc 'Sends weekly notifications for expired certification'
      task :expired => :environment do
        Notification::CertificationNotificationService.new.send_expired_notifications(:weekly)
      end

      desc 'Sends weekly notifications for expiring certification'
      task :expiring => :environment do
        Notification::CertificationNotificationService.new.send_expiring_notifications(:weekly)
      end
    end
  end
end