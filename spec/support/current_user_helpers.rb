module CurrentUserHelpers
  def stub_current_user_with(user)
    controller.stub(:current_user).and_return(user)
    user
  end

  def stub_equipment_user
    stub_current_user_with(create_user(roles: ['equipment'], customer: @customer))
  end

  def stub_certification_user
    stub_current_user_with(create_user(roles: ['certification'], customer: @customer))
  end

  def stub_guest_user
    stub_current_user_with(create_user(customer: @customer))
  end

  def stub_admin
    stub_current_user_with(create_user(roles: ['admin']))
  end
end