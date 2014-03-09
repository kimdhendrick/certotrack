module LoginHelpers
  def login_as_equipment_user(customer = nil)
    login_as_user_with_role('equipment', {customer: customer})
  end

  def login_as_vehicle_user(customer = nil)
    login_as_user_with_role('vehicle', {customer: customer})
  end

  def login_as_certification_user(customer = nil)
    login_as_user_with_role('certification', {customer: customer})
  end

  def login_as_admin
    login_as_user_with_role('admin')
  end

  def login_as_guest
    login_as(create(:user))
  end

  def login_as_equipment_and_certification_user(customer = nil)
    customer ||= create(:customer)
    user = create(:user, customer: customer, roles: ['equipment', 'certification'])
    login_as(user)
  end

  def login_as_user_with_role(role, params)
    customer = params[:customer] || create(:customer)
    user = create(:user, customer: customer, roles: [role])

    login_as(user)
  end

  def login_as(user)
    visit "#"
    fill_in 'Username', with: user.username.upcase
    fill_in 'Password', with: user.password
    click_button 'Login'
  end
end