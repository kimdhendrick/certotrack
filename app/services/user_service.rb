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
    user.update(attributes)
    user.roles = user.customer.roles

    user.save && _update_password_histories(user)
  end

  def delete_user(user)
    user.destroy
  end

  private

  def _update_password_histories(user)
    user.password_histories <<
      PasswordHistory.new(encrypted_password: user.encrypted_password)

    recent_password_histories = user.
      password_histories.
      sort_by(&:created_at).
      reverse.
      first(5)

    (user.password_histories - recent_password_histories).each do |history|
      history.delete
    end
  end
end