ActionMailer::Base.smtp_settings = {
  :address              => ENV['CERTOTRACK_EMAIL_ADDRESS'],
  :port                 => ENV['CERTOTRACK_EMAIL_PORT'],
  :domain               => ENV['CERTOTRACK_EMAIL_DOMAIN'],
  :user_name            => ENV['CERTOTRACK_EMAIL_USERNAME'],
  :password             => ENV['CERTOTRACK_EMAIL_PASSWORD'],
  :authentication       => :plain,
  :enable_starttls_auto => true
}