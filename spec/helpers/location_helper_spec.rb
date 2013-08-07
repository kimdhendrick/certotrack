require 'spec_helper'

describe LocationHelper do

  it "should provide location's accessible parameters" do
    LocationHelper.accessible_parameters.should == [
      :name
    ]
  end
end