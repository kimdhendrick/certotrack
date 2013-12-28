require 'spec_helper'

describe ExpirationCalculator do
  describe '#calculate' do
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

  describe '#calculate_mileage' do
    it 'should calculate expiration mileage' do
      start_mileage = 10000

      calculator = ExpirationCalculator.new

      calculator.calculate_mileage(start_mileage, 3000).should == 13000
      calculator.calculate_mileage(start_mileage, 15000).should == 25000
      calculator.calculate_mileage(start_mileage, 50000).should == 60000
    end

    it 'should return nil for nil start mileage' do
      ExpirationCalculator.new.calculate_mileage(nil, 1).should be_nil
    end
  end
end