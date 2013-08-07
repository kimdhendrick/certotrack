require 'spec_helper'

describe Employee do
  before { @employee = new_employee }

  subject { @employee }

  it { should belong_to(:customer) }

  it 'should display its name as to_s' do
    @employee.first_name = 'John'
    @employee.last_name = 'Doe'
    @employee.to_s.should == 'Doe, John'
  end
end
