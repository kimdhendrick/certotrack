require 'spec_helper'

describe EquipmentHelper do

  it "should provide equipment's accessible parameters" do
    equipment_accessible_parameters.should == [
      :name,
      :serial_number,
      :inspection_interval,
      :last_inspection_date,
      :comments,
      :location_id,
      :employee_id
    ]
  end
  
  it 'should display assigned to properly' do
    location_assigned_equipment = build(:location_assigned_equipment)
    employee_assigned_equipment = build(:equipment, employee: build(:employee, first_name: 'Joe', last_name: 'Doe'))
    unassigned_equipment = build(:equipment)

    display_assigned_to(location_assigned_equipment).should == 'Denver'
    display_assigned_to(employee_assigned_equipment).should == 'Doe, Joe'
    display_assigned_to(unassigned_equipment).should == 'Unassigned'
  end
end