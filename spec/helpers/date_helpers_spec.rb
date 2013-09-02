require 'spec_helper'

describe DateHelpers do
  describe 'date_to_string' do
    it 'should format date' do
      DateHelpers.date_to_string(Date.new(2014, 12, 31)).should == '12/31/2014'
      DateHelpers.date_to_string(Date.new(2012, 1, 2)).should == '01/02/2012'
    end

    it 'should handle nil date' do
      DateHelpers.date_to_string(nil).should == ''
    end
  end

  describe 'string_to_date' do
    it 'should return nil on bad date format' do
      DateHelpers.string_to_date(nil).should be_nil
      DateHelpers.string_to_date('1111').should be_nil
      DateHelpers.string_to_date('1/1/2000').should == Date.new(2000,1,1)
    end
  end
end