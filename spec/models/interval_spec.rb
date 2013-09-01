require 'spec_helper'

describe Interval do
  it 'should display as strings' do
    Interval::ONE_MONTH.to_s.should == '1 month'
    Interval::THREE_MONTHS.to_s.should == '3 months'
    Interval::SIX_MONTHS.to_s.should == '6 months'
    Interval::ONE_YEAR.to_s.should == 'Annually'
    Interval::TWO_YEARS.to_s.should == '2 years'
    Interval::THREE_YEARS.to_s.should == '3 years'
    Interval::FIVE_YEARS.to_s.should == '5 years'
    Interval::NOT_REQUIRED.to_s.should == 'Not Required'
  end
end