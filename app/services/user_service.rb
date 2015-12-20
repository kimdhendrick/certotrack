class UserService
  def get_all_users(current_user)
    current_user.admin? ? User.all : User.where(customer: current_user.customer)
  end

  def create_user(attributes)
    user = User.new(attributes)
    user.roles = user.customer.roles
    user.save
    user
  end

  def update_user(user, attributes)
    attributes.delete('password') unless attributes['password'].present?
    user.update(attributes)
    user.roles = user.customer.roles
    user.save
  end

  def delete_user(current_user, user)
    return false if current_user == user

    user.destroy
  end
end