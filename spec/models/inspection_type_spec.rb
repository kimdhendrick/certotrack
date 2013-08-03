require 'spec_helper'

describe InspectionType do
  it 'should display as strings' do
    InspectionType::INSPECTABLE.to_s.should == 'Inspectable'
    InspectionType::NON_INSPECTABLE.to_s.should == 'Non-Inspectable'
  end
end