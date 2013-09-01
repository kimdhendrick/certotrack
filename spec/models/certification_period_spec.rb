require 'spec_helper'

describe CertificationPeriod do
  it { should belong_to(:certification) }

  it 'should default units_achieved to 0' do
    CertificationPeriod.new.units_achieved.should == 0
  end
end
