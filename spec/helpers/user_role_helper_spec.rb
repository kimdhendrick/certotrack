require 'spec_helper'

describe UserRoleHelper do
  describe 'add_role' do
    it 'should add the new role' do
      equipment_user = create(:user)
      equipment_user.role?('equipment').should be_false

      UserRoleHelper::add_role(equipment_user, 'equipment')

      equipment_user.role?('equipment').should be_true
    end
  end

  describe 'remove_role' do
    it 'should remove the old role' do
      equipment_user = create(:user, roles: ['equipment'])
      equipment_user.role?('equipment').should be_true

      UserRoleHelper::remove_role(equipment_user, 'equipment')

      equipment_user.role?('equipment').should be_false
    end
  end
end