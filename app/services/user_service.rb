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
    user.save
  end

  def delete_user(user)
    user.destroy
  end
end