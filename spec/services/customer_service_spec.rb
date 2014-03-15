require 'spec_helper'

describe CustomerService do
  describe 'get_all_customers' do
    let(:my_customer) { create(:customer, name: 'A Customer') }
    let!(:other_customer) { create(:customer, name: 'Another Customer') }

    context 'when admin user' do
      it 'should return all customers' do
        admin_user = create(:user, admin: true, customer: other_customer)

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

  describe 'update_customer' do

    let(:customer) do
      create(
        :customer,
        name: 'My Customer Name',
        account_number: 'ABC123',
        contact_person_name: 'Joe Blow',
        contact_phone_number: '(303) 222-1234',
        contact_email: 'joe@example.com',
        address1: '123 Main St',
        address2: 'Suite 100',
        city: 'Denver',
        state: 'CO',
        zip: '80222',
        equipment_access: false,
        certification_access: false,
        vehicle_access: false
      )
    end

    let(:attributes) do
      {
        'id' => customer.id,
        'name' => 'CustomerName',
        'account_number' => 'newAN',
        'contact_person_name' => 'Joey',
        'contact_phone_number' => '123123123',
        'contact_email' => 'blah@boo.com',
        'address1' => '111 One Street',
        'address2' => '222 Two Avenue',
        'city' => 'Tampa',
        'state' => 'FL',
        'zip' => '98980',
        'equipment_access' => 'true',
        'certification_access' => 'true',
        'vehicle_access' => 'true'
      }
    end

    it "should update customer's attributes" do
      success = CustomerService.new.update_customer(customer, attributes)
      success.should be_true

      customer.reload
      customer.name.should == 'CustomerName'
      customer.account_number.should == 'newAN'
      customer.contact_person_name.should == 'Joey'
      customer.contact_phone_number.should == '123123123'
      customer.contact_email.should == 'blah@boo.com'
      customer.address1.should == '111 One Street'
      customer.address2.should == '222 Two Avenue'
      customer.city.should == 'Tampa'
      customer.state.should == 'FL'
      customer.zip.should == '98980'
      customer.equipment_access.should be_true
      customer.certification_access.should be_true
      customer.vehicle_access.should be_true
    end

    it 'should return false if errors' do
      customer = create(:customer)
      customer.stub(:save).and_return(false)

      success = CustomerService.new.update_customer(customer, attributes)
      success.should be_false

      customer.reload
      customer.name.should_not == 'CustomerName'
    end

    it "should update customer's users' vehicle access" do
      customer = create(:customer, vehicle_access: false)
      my_user = create(:user, customer: customer)
      other_user = create(:user)
      my_user.role?('vehicle').should be_false
      other_user.role?('vehicle').should be_false

      success = CustomerService.new.update_customer(customer, {'vehicle_access' => true})

      success.should be_true

      my_user.reload
      my_user.role?('vehicle').should be_true
      other_user.reload
      other_user.role?('vehicle').should be_false
    end

    it "should update customer's users' equipment access" do
      customer = create(:customer, equipment_access: false)
      my_user = create(:user, customer: customer)
      other_user = create(:user)
      my_user.role?('equipment').should be_false
      other_user.role?('equipment').should be_false

      success = CustomerService.new.update_customer(customer, {'equipment_access' => true})

      success.should be_true

      my_user.reload
      my_user.role?('equipment').should be_true
      other_user.reload
      other_user.role?('equipment').should be_false
    end

    it "should update customer's users' certification access" do
      customer = create(:customer, certification_access: false)
      my_user = create(:user, customer: customer)
      other_user = create(:user)
      my_user.role?('certification').should be_false
      other_user.role?('certification').should be_false

      success = CustomerService.new.update_customer(customer, {'certification_access' => true})

      success.should be_true

      my_user.reload
      my_user.role?('certification').should be_true
      other_user.reload
      other_user.role?('certification').should be_false
    end

    it 'should return false if user save fails' do
      customer = create(:customer)
      create(:user, customer: customer)
      User.any_instance.stub(:save).and_return(false)

      success = CustomerService.new.update_customer(customer, {})

      success.should be_false
    end

    it 'only gets the vehicle role once' do
      customer = create(:customer, vehicle_access: true)
      my_user = create(:user, customer: customer)
      my_user.roles = ['vehicle']
      my_user.save

      success = CustomerService.new.update_customer(customer, {})

      success.should be_true
      my_user.reload
      my_user.roles.should == ['vehicle']
    end
  end
end