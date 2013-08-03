require 'spec_helper'

describe DateHelpers do
  describe 'format' do
    it 'should format date' do
      DateHelpers.format(Date.new(2014, 12, 31)).should == '12/31/2014'
      DateHelpers.format(Date.new(2012, 1, 2)).should == '01/02/2012'
    end

    it 'should handle nil date' do
      DateHelpers.format(nil).should == ''
    end
  end
end