require 'spec_helper'

describe Location do
  before { @location = build(:location) }

  subject { @location }

  it { should belong_to(:customer) }
  it { should validate_presence_of :customer }

  it 'should display its name as to_s' do
    @location.name = 'My Location'
    @location.to_s.should == 'My Location'
  end
end
