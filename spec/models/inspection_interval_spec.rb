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

  describe 'expires_on' do
    it 'should calculate expires on date' do
      start_date = Date.new(2010, 1, 1)

      InspectionInterval::ONE_MONTH.expires_on(start_date).should == Date.new(2010, 2, 1)
      InspectionInterval::THREE_MONTHS.expires_on(start_date).should == Date.new(2010, 4, 1)
      InspectionInterval::SIX_MONTHS.expires_on(start_date).should == Date.new(2010, 7, 1)
      InspectionInterval::ONE_YEAR.expires_on(start_date).should == Date.new(2011, 1, 1)
      InspectionInterval::TWO_YEARS.expires_on(start_date).should == Date.new(2012, 1, 1)
      InspectionInterval::THREE_YEARS.expires_on(start_date).should == Date.new(2013, 1, 1)
      InspectionInterval::FIVE_YEARS.expires_on(start_date).should == Date.new(2015, 1, 1)
      InspectionInterval::NOT_REQUIRED.expires_on(start_date).should be_nil
    end

    it 'should return nil for nil start date' do
      InspectionInterval::ONE_MONTH.expires_on(nil).should be_nil
    end
  end
end