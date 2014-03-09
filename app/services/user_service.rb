class UserService
  def get_all_users(current_user)
    User.all if current_user.admin?
  end

  def create_user(current_user, attributes)
    return unless current_user.admin?

    user = User.new(attributes)
    user.roles = user.customer.roles
    user.save
    user
  end
end