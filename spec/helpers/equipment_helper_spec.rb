require 'spec_helper'

describe EquipmentHelper do

  it "should provide equipment's accessible parameters" do
    equipment_accessible_parameters.should == [
      :name,
      :serial_number,
      :inspection_interval,
      :last_inspection_date,
      :notes,
      :location_id,
      :employee_id
    ]
  end
  
  it 'should display assigned to properly' do
    location_assigned_equipment = new_equipment(location: new_location(name: 'Golden'))
    employee_assigned_equipment = new_equipment(employee: new_employee(first_name: 'Joe', last_name: 'Doe'))
    unassigned_equipment = new_equipment

    display_assigned_to(location_assigned_equipment).should == 'Golden'
    display_assigned_to(employee_assigned_equipment).should == 'Doe, Joe'
    display_assigned_to(unassigned_equipment).should == 'Unassigned'
  end
end