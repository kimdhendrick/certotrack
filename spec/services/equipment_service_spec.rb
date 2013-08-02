require 'spec_helper'

describe EquipmentService do
  describe 'get_all_equipment' do
    before do
      @customer_one = create_valid_customer
      @equipment_one = create_valid_equipment(customer: @customer_one)
      @equipment_two = create_valid_equipment(customer: create_valid_customer)
    end

    context 'an admin user' do
      it 'should return all equipment' do
        admin_user = create_valid_user(roles: ['admin'])

        EquipmentService::get_all_equipment(admin_user).should == [@equipment_one, @equipment_two]
      end
    end

    context 'a regular user' do
      it "should return only that user's equipment" do
        user = create_valid_user(customer: @customer_one)

        EquipmentService::get_all_equipment(user).should == [@equipment_one]
      end
    end
  end

  describe 'count_all_equipment' do
    before do
      @customer_one = create_valid_customer
      @equipment_one = create_valid_equipment(customer: @customer_one)
      @equipment_two = create_valid_equipment(customer: create_valid_customer)
    end

    context 'an admin user' do
      it 'should return count that includes all equipment' do
        admin_user = create_valid_user(roles: ['admin'])

        EquipmentService::count_all_equipment(admin_user).should == 2
      end
    end

    context 'a regular user' do
      it "should return count that includes only that user's equipment" do
        user = create_valid_user(customer: @customer_one)

        EquipmentService::count_all_equipment(user).should == 1
      end
    end
  end

  describe 'count_expired_equipment' do
    before do
      @customer_one = create_valid_customer
      @customer_two = create_valid_customer
      @valid_equipment_customer_one = create_valid_equipment(customer: @customer_one, expiration_date: Date.today + 61.days)
      @valid_equipment_customer_two = create_valid_equipment(customer: @customer_two, expiration_date: Date.today + 61.days)
      @expired_equipment_customer_one = create_valid_equipment(customer: @customer_one, expiration_date: Date.yesterday)
      @expired_equipment_customer_two = create_valid_equipment(customer: @customer_two, expiration_date: Date.yesterday)
    end

    context 'an admin user' do
      it 'should return count that includes all expired equipment' do
        admin_user = create_valid_user(roles: ['admin'])

        EquipmentService::count_expired_equipment(admin_user).should == 2
      end
    end

    context 'a regular user' do
      it "should return count that includes only that user's expired equipment" do
        user = create_valid_user(customer: @customer_one)

        EquipmentService::count_expired_equipment(user).should == 1
      end
    end
  end

  describe 'count_expiring_equipment' do
    before do
      @customer_one = create_valid_customer
      @customer_two = create_valid_customer
      @customer_three = create_valid_customer
      @valid_equipment_customer_one = create_valid_equipment(customer: @customer_one, expiration_date: Date.today + 61.days)
      @valid_equipment_customer_two = create_valid_equipment(customer: @customer_two, expiration_date: Date.today + 61.days)
      @valid_equipment_customer_three = create_valid_equipment(customer: @customer_three, expiration_date: Date.today + 61.days)
      @expiring_equipment_customer_one = create_valid_equipment(customer: @customer_one, expiration_date: Date.tomorrow)
      @expiring_equipment_customer_two = create_valid_equipment(customer: @customer_two, expiration_date: Date.tomorrow)
    end

    context 'an admin user' do
      it 'should return count that includes all expiring equipment' do
        admin_user = create_valid_user(roles: ['admin'])

        EquipmentService::count_expiring_equipment(admin_user).should == 2
      end
    end

    context 'a regular user' do
      it "should return count that includes only that user's expiring equipment" do
        user = create_valid_user(customer: @customer_one)

        EquipmentService::count_expiring_equipment(user).should == 1
      end
    end
  end
end