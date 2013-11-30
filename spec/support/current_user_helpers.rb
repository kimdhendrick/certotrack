module CurrentUserHelpers
  def stub_current_user_with(user)
    controller.stub(:current_user).and_return(user)
    user
  end

  def stub_equipment_user(customer = nil)
    stub_current_user_with(_create_stub_user_with_roles(['equipment'], customer))
  end

  def stub_certification_user(customer = nil)
    stub_current_user_with(_create_stub_user_with_roles(['certification'], customer))
  end

  def stub_vehicle_user(customer = nil)
    stub_current_user_with(_create_stub_user_with_roles(['vehicle'], customer))
  end

  def stub_guest_user
    stub_current_user_with(_create_stub_user_with_roles([]))
  end

  def stub_admin(customer = nil)
    stub_current_user_with(_create_stub_user_with_roles(['admin'], customer))
  end

  def _create_stub_user_with_roles(roles, customer = nil)
    customer ||= create(:customer)
    stub_current_user_with(create(:user, roles: roles, customer: customer))
  end
end