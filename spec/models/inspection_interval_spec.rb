require 'spec_helper'

describe InspectionInterval do
  it 'should display as strings' do
    InspectionInterval::ONE_MONTH.to_s.should == '1 month'
    InspectionInterval::THREE_MONTHS.to_s.should == '3 months'
    InspectionInterval::SIX_MONTHS.to_s.should == '6 months'
    InspectionInterval::ONE_YEAR.to_s.should == 'Annually'
    InspectionInterval::TWO_YEARS.to_s.should == '2 years'
    InspectionInterval::THREE_YEARS.to_s.should == '3 years'
    InspectionInterval::FIVE_YEARS.to_s.should == '5 years'
    InspectionInterval::NOT_REQUIRED.to_s.should == 'Not Required'
  end
end