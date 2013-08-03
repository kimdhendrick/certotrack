module LoginHelpers
  def login_as_user_with_role(role)
    visit "#"
    @customer = create_customer
    user = create_user(customer: @customer, roles: [role])
    fill_in 'Username', with: user.username.upcase
    fill_in 'Password', with: user.password
    click_button 'Login'
  end

  def login_as_equipment_user
    login_as_user_with_role('equipment')
  end

  def login_as_admin
    login_as_user_with_role('admin')
  end

  def login_as_guest
    visit "#"
    @customer = create_customer
    user = create_user(customer: @customer)
    fill_in 'Username', with: user.username.upcase
    fill_in 'Password', with: user.password
    click_button 'Login'
  end
end