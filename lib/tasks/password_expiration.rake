namespace :expire do
  desc 'Sends daily notifications for expired equipment'
  task :passwords => :environment do
    PasswordExpirationService.new.execute
  end
end