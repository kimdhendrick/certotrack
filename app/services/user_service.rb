class UserService
  def get_all_users(current_user)
    User.all if current_user.admin?
  end
end