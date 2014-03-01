require 'spec_helper'

describe CustomerService do
  describe 'get_all_customers' do
    let(:my_customer) { create(:customer, name: 'A Customer') }
    let!(:other_customer) { create(:customer, name: 'Another Customer') }

    context 'when admin user' do
      it 'should return all customers' do
        admin_user = create(:user, roles: ['admin'], customer: other_customer)

        customers = subject.get_all_customers(admin_user)

        customers.should =~ [my_customer, other_customer]
      end
    end

    context 'when regular user' do
      it 'should return nada' do
        user = create(:user, customer: my_customer)

        customers = subject.get_all_customers(user)

        customers.should be_nil
      end
    end
  end

  describe 'create_customer' do
    it 'should create a new customer' do
      attributes =
        {
          name: 'Government',
          account_number: 'ABC123',
          equipment_access: 'true',
          certification_access: 'false',
          vehicle_access: 'true',
          contact_person_name: 'Joe Blow',
          contact_phone_number: '(303) 222-3333',
          contact_email: 'joe@example.com',
          address1: '123 Main St',
          address2: 'Suite 100',
          city: 'Denver',
          state: 'CO',
          zip: '80222'
        }

      customer = subject.create_customer(attributes)

      customer.should be_persisted
      customer.name.should == 'Government'
      customer.account_number.should == 'ABC123'
      customer.equipment_access.should be_true
      customer.vehicle_access.should be_true
      customer.certification_access.should be_false
      customer.contact_person_name.should == 'Joe Blow'
      customer.contact_phone_number.should == '(303) 222-3333'
      customer.contact_email.should == 'joe@example.com'
      customer.address1.should == '123 Main St'
      customer.address2.should == 'Suite 100'
      customer.city.should == 'Denver'
      customer.state.should == 'CO'
      customer.zip.should == '80222'
    end
  end
end