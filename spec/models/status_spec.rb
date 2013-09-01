require 'spec_helper'

describe Status do
  it 'should display as strings' do
    Status::VALID.to_s.should == 'Valid'
    Status::EXPIRING.to_s.should == 'Warning'
    Status::EXPIRED.to_s.should == 'Expired'
    Status::RECERTIFY.to_s.should == 'Recertify'
    Status::PENDING.to_s.should == 'Pending'
    Status::NA.to_s.should == 'N/A'
  end

  it 'should have sort_order' do
    Status::VALID.sort_order.should == 1
    Status::EXPIRING.sort_order.should == 2
    Status::EXPIRED.sort_order.should == 3
    Status::RECERTIFY.sort_order.should == 4
    Status::PENDING.sort_order.should == 5
    Status::NA.sort_order.should == 6
  end
end