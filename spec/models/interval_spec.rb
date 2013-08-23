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

  describe 'expires_on' do
    it 'should calculate expires on date' do
      start_date = Date.new(2010, 1, 1)

      Interval::ONE_MONTH.expires_on(start_date).should == Date.new(2010, 2, 1)
      Interval::THREE_MONTHS.expires_on(start_date).should == Date.new(2010, 4, 1)
      Interval::SIX_MONTHS.expires_on(start_date).should == Date.new(2010, 7, 1)
      Interval::ONE_YEAR.expires_on(start_date).should == Date.new(2011, 1, 1)
      Interval::TWO_YEARS.expires_on(start_date).should == Date.new(2012, 1, 1)
      Interval::THREE_YEARS.expires_on(start_date).should == Date.new(2013, 1, 1)
      Interval::FIVE_YEARS.expires_on(start_date).should == Date.new(2015, 1, 1)
      Interval::NOT_REQUIRED.expires_on(start_date).should be_nil
    end

    it 'should return nil for nil start date' do
      Interval::ONE_MONTH.expires_on(nil).should be_nil
    end
  end
end