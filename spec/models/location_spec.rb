require 'spec_helper'

describe Location do
  before { @location = new_location }

  subject { @location }

  it { should belong_to(:customer) }

  it 'should display its name as to_s' do
    @location.name = 'My Location'
    @location.to_s.should == 'My Location'
  end
end