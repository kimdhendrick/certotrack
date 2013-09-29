require 'spec_helper'

describe EquipmentPresenter do
  context '#assigned_to' do
    it 'should return location name' do
      location = create(:location, name: 'Florida')
      location_assigned_equipment = create(:equipment, location: location)

      EquipmentPresenter.new(location_assigned_equipment, nil).assigned_to.should == 'Florida'
    end

    it 'should return employee name' do
      employee = create(:employee, first_name: 'John', last_name: 'Smith')
      employee_assigned_equipment = create(:equipment, employee: employee)

      EquipmentPresenter.new(employee_assigned_equipment, nil).assigned_to.should == 'Smith, John'
    end

    it 'should return Unassigned' do
      unassigned_equipment = create(:equipment, employee: nil, location: nil)

      EquipmentPresenter.new(unassigned_equipment, nil).assigned_to.should == 'Unassigned'
    end
  end
end