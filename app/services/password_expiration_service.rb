class PasswordExpirationService
  def execute
    User.where('password_last_changed < :date OR password_last_changed IS NULL',{date: 90.days.ago}).each do |user|
      user.update_attribute(:password_expired, true)
    end
  end
end
