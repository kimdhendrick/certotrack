require 'spec_helper'

describe Equipment do
  before { @equipment = new_valid_equipment }

  subject { @equipment }

  it { should belong_to(:customer) }

  it 'should provide its accessible parameters' do
    Equipment.accessible_parameters.should == [
      :name,
      :serial_number,
      :inspection_interval,
      :last_inspection_date,
      :inspection_type,
      :notes
    ]
  end

  it 'should be able to assign a customer to equipment' do
    customer = new_valid_customer
    equipment = new_valid_user
    equipment.customer = customer

    equipment.customer.should == customer
  end
end
