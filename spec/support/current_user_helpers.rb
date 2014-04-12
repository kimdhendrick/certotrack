module CurrentUserHelpers
  def stub_current_user_with(user)
    controller.stub(:current_user).and_return(user)
    user
  end

  def stub_equipment_user(customer = nil)
    stub_current_user_with(create_stub_user_with_roles(['equipment'], {customer: customer}))
  end

  def stub_certification_user(customer = nil)
    stub_current_user_with(create_stub_user_with_roles(['certification'], {customer: customer}))
  end

  def stub_vehicle_user(customer = nil)
    stub_current_user_with(create_stub_user_with_roles(['vehicle'], {customer: customer}))
  end

  def stub_guest_user
    stub_current_user_with(create_stub_user_with_roles([]))
  end

  def stub_admin(customer = nil)
    stub_current_user_with(create_stub_user_with_roles([], {customer: customer, admin: true}))
  end

  def create_stub_user_with_roles(roles, params = {})
    customer = params[:customer] || create(:customer)
    admin = params[:admin] || false

    stub_current_user_with(create(:user, roles: roles, admin: admin, customer: customer))
  end
end