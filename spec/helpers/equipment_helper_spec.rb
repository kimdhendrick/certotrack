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
end