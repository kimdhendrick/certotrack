module CurrentUserHelpers
  def stub_current_user_with(user)
    controller.stub(:current_user).and_return(user)
    user
  end

  def stub_equipment_user
    stub_current_user_with(_create_stub_user_with_roles(['equipment']))
  end

  def stub_certification_user
    stub_current_user_with(_create_stub_user_with_roles(['certification']))
  end

  def stub_guest_user
    stub_current_user_with(_create_stub_user_with_roles([]))
  end

  def stub_admin
    stub_current_user_with(_create_stub_user_with_roles(['admin']))
  end

  def _create_stub_user_with_roles(roles)
    @customer ||= create(:customer)
    stub_current_user_with(create(:user, roles: roles, customer: @customer))
  end
end