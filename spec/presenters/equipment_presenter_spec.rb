require 'spec_helper'

describe EquipmentPresenter do
  it 'should respond to location name' do
    location = create(:location, name: 'Florida')
    location_assigned_equipment = create(:equipment, location: location)

    EquipmentPresenter.new(location_assigned_equipment, nil).assignee.should == 'Florida'
  end

  it 'should respond to employee name' do
    employee = create(:employee, first_name: 'John', last_name: 'Smith')
    employee_assigned_equipment = create(:equipment, employee: employee)

    EquipmentPresenter.new(employee_assigned_equipment, nil).assignee.should == 'Smith, John'
  end

  it 'should respond to Unassigned' do
    unassigned_equipment = create(:equipment, employee: nil, location: nil)

    EquipmentPresenter.new(unassigned_equipment, nil).assignee.should == 'Unassigned'
  end

  it 'should respond to assignee' do
    location = create(:location, name: 'Location Name')
    location_assigned_equipment = EquipmentPresenter.new(create(:equipment, location_id: location.id))
    employee = create(:employee, first_name: 'Joe', last_name: 'Schmoe')
    employee_assigned_equipment = EquipmentPresenter.new(create(:equipment, employee_id: employee.id))

    location_assigned_equipment.assignee.should == 'Location Name'
    employee_assigned_equipment.assignee.should == 'Schmoe, Joe'
  end

  it 'should respond to sort_key' do
    equipment = EquipmentPresenter.new(create(:equipment, name: 'Equipment Name'))
    equipment.sort_key.should == 'Equipment Name'
  end

  it 'should respond to inspection_interval_code' do
    equipment = EquipmentPresenter.new(create(:equipment, inspection_interval: Interval::THREE_MONTHS.text))
    equipment.inspection_interval_code.should == Interval::THREE_MONTHS.id
  end

  it 'should respond to last_inspection_date' do
    equipment = EquipmentPresenter.new(create(:equipment, last_inspection_date: Date.new(2013, 5, 12)))
    equipment.last_inspection_date.should == "05/12/2013"
  end

  it 'should respond to expiration_date' do
    equipment = EquipmentPresenter.new(create(:equipment, expiration_date: Date.new(2012, 6, 20)))
    equipment.expiration_date.should == "06/20/2012"
  end
end