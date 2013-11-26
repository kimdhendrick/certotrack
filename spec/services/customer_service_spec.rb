require 'spec_helper'

describe CustomerService do
  let(:my_customer) { create(:customer, name: 'A Customer') }
  let!(:other_customer) { create(:customer, name: 'Another Customer') }

  context 'when admin user' do
    it 'should return all customers' do
      admin_user = create(:user, roles: ['admin'], customer: other_customer)

      customers = CustomerService.new.get_all_customers(admin_user)

      customers.should =~ [my_customer, other_customer]
    end
  end

  context 'when regular user' do
    it 'should return nada' do
      user = create(:user, customer: my_customer)

      customers = CustomerService.new.get_all_customers(user)

      customers.should be_nil
    end
  end
end