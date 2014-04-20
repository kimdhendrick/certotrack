class UserService
  def get_all_users
    User.all
  end

  def create_user(attributes)
    user = User.new(attributes)
    user.roles = user.customer.roles
    user.save
    user
  end

  def update_user(user, attributes)
    new_password = attributes.delete('password')

    user.update(attributes)
    user.roles = user.customer.roles

    _update_password(user, new_password)
    user.save
  end

  def delete_user(user)
    user.destroy
  end

  private

  def _update_password(user, new_password)
    return unless new_password.present?

    _add_new_password_history(user, user.encrypted_password)
    _purge_old_password_histories(user)
    user.password = new_password
    _update_password_last_changed_date(user)
  end

  def _update_password_last_changed_date(user)
    user.update_attribute(:password_last_changed, DateTime.now)
  end

  def _purge_old_password_histories(user)
    recent_password_histories = user.
      password_histories.
      sort_by(&:created_at).
      reverse.
      first(5)

    (user.password_histories - recent_password_histories).each do |history|
      history.delete
    end
  end

  def _add_new_password_history(user, old_password)
    user.password_histories <<
      PasswordHistory.new(encrypted_password: old_password)
  end
end