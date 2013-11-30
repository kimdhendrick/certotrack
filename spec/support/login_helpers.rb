module LoginHelpers
  def login_as_user_with_role(role, customer = nil)
    visit "#"
    customer ||= create(:customer)
    user = create(:user, customer: customer, roles: [role])
    fill_in 'Username', with: user.username.upcase
    fill_in 'Password', with: user.password
    click_button 'Login'
  end

  def login_as_equipment_user(customer = nil)
    login_as_user_with_role('equipment', customer)
  end

  def login_as_vehicle_user(customer = nil)
    login_as_user_with_role('vehicle', customer)
  end

  def login_as_certification_user(customer = nil)
    login_as_user_with_role('certification', customer)
  end

  def login_as_equipment_and_certification_user(customer = nil)
    visit "#"
    customer ||= create(:customer)
    user = create(:user, customer: customer, roles: ['equipment', 'certification'])
    fill_in 'Username', with: user.username.upcase
    fill_in 'Password', with: user.password
    click_button 'Login'
  end

  def login_as_admin
    login_as_user_with_role('admin')
  end

  def login_as_guest
    visit "#"
    customer = create(:customer)
    user = create(:user, customer: customer)
    fill_in 'Username', with: user.username.upcase
    fill_in 'Password', with: user.password
    click_button 'Login'
  end
end