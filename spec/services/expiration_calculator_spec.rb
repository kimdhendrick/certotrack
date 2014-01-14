require 'spec_helper'

describe ExpirationCalculator do
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