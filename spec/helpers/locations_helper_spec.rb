require 'spec_helper'

describe LocationsHelper do

  it "should provide location's accessible parameters" do
    location_accessible_parameters.should == [
      :name,
      :customer_id
    ]
  end
end