module LoginHelpers
  def login_as_equipment_user(customer = nil)
    _login_as_user_with_roles(['equipment'], {customer: customer})
  end

  def login_as_vehicle_user(customer = nil)
    _login_as_user_with_roles(['vehicle'], {customer: customer})
  end

  def login_as_certification_user(customer = nil)
    _login_as_user_with_roles(['certification'], {customer: customer})
  end

  def login_as_equipment_and_certification_user(customer = nil)
    _login_as_user_with_roles(['equipment', 'certification'], {customer: customer})
  end

  def login_as_admin
    login_as(create(:user, admin: true))
  end

  def login_as_guest
    login_as(create(:user))
  end

  def login_as(user)
    visit dashboard_path
    fill_in 'Username', with: user.username.upcase
    fill_in 'Password', with: user.password
    click_button 'Login'
  end

  private

  def _login_as_user_with_roles(roles, params)
    customer = params[:customer] || create(:customer)
    user = create(:user, customer: customer, roles: roles)

    login_as(user)
    user
  end
end