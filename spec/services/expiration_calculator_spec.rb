require 'spec_helper'

describe ExpirationCalculator do
  describe 'calculate' do
    it 'should calculate expiration date' do
      start_date = Date.new(2010, 1, 1)

      calculator = ExpirationCalculator.new

      calculator.calculate(start_date, Interval::ONE_MONTH).should == Date.new(2010, 2, 1)
      calculator.calculate(start_date, Interval::THREE_MONTHS).should == Date.new(2010, 4, 1)
      calculator.calculate(start_date, Interval::SIX_MONTHS).should == Date.new(2010, 7, 1)
      calculator.calculate(start_date, Interval::ONE_YEAR).should == Date.new(2011, 1, 1)
      calculator.calculate(start_date, Interval::TWO_YEARS).should == Date.new(2012, 1, 1)
      calculator.calculate(start_date, Interval::THREE_YEARS).should == Date.new(2013, 1, 1)
      calculator.calculate(start_date, Interval::FIVE_YEARS).should == Date.new(2015, 1, 1)
      calculator.calculate(start_date, Interval::NOT_REQUIRED).should be_nil
    end

    it 'should return nil for nil start date' do
      ExpirationCalculator.new.calculate(nil, Interval::ONE_MONTH).should be_nil
    end
  end
end