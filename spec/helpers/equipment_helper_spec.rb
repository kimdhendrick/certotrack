require 'spec_helper'

describe EquipmentHelper do

  it "should provide equipment's accessible parameters" do
    EquipmentHelper.accessible_parameters.should == [
      :name,
      :serial_number,
      :inspection_interval,
      :last_inspection_date,
      :inspection_type,
      :notes,
      :location_id
    ]
  end

end