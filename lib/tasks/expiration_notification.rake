namespace :notification do
  namespace :equipment do
    desc 'Sends notifications for expired equipment'
    task :expired => :environment do
      Notification::EquipmentNotificationService.new.send_expired_notifications(:daily)
    end

    desc 'Sends notifications for expiring equipment'
    task :expiring => :environment do
      puts 'to do'
    end
  end

  namespace :certifications do
    desc 'Sends notifications for expired certifications'
    task :expired => :environment do
      puts 'to do'
    end

    desc 'Sends notifications for expiring certifications'
    task :expiring => :environment do
      puts 'to do'
    end
  end
end