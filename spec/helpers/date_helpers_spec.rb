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
end