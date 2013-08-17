require 'spec_helper'

describe EquipmentService do
  describe 'get_all_equipment' do
    before do
      @my_customer = create_customer
      @my_user = create_user(customer: @my_customer)
    end

    context 'sorting' do
      it 'should call Sort Service to ensure sorting' do
        equipment_service = EquipmentService.new
        fake_sort_service = equipment_service.load_sort_service(FakeSortService.new)

        equipment_service.get_all_equipment(@my_user)

        fake_sort_service.received_message.should == :sort
      end
    end

    context 'an admin user' do
      it 'should return all equipment' do
        my_equipment = create_equipment(customer: @my_customer)
        other_equipment = create_equipment(customer: create_customer)

        admin_user = create_user(roles: ['admin'])

        EquipmentService.new.get_all_equipment(admin_user).should == [my_equipment, other_equipment]
      end
    end

    context 'a regular user' do
      it "should return only that user's equipment" do
        my_equipment = create_equipment(customer: @my_customer)
        other_equipment = create_equipment(customer: create_customer)

        EquipmentService.new.get_all_equipment(@my_user).should == [my_equipment]
      end
    end
  end

  describe 'get_expired_equipment' do
    before do
      @my_customer = create_customer
      @my_expired_equipment = create_expired_equipment(customer: @my_customer)
      @other_expired_equipment = create_expired_equipment(customer: create_customer)
      @my_valid_equipment = create_valid_equipment(customer: @my_customer)
      @other_valid_equipment = create_valid_equipment(customer: create_customer)
      @my_expiring_equipment = create_expiring_equipment(customer: @my_customer)
      @other_expiring_equipment = create_expiring_equipment(customer: create_customer)
    end

    context 'sorting' do
      it 'should call Sort Service to ensure sorting' do
        equipment_service = EquipmentService.new
        fake_sort_service = equipment_service.load_sort_service(FakeSortService.new)

        equipment_service.get_expired_equipment(create_user(customer: @my_customer))

        fake_sort_service.received_message.should == :sort
      end
    end

    context 'an admin user' do
      it 'should return all expired equipment' do
        admin_user = create_user(roles: ['admin'])

        EquipmentService.new.get_expired_equipment(admin_user).should == [@my_expired_equipment, @other_expired_equipment]
      end
    end

    context 'a regular user' do
      it "should return only that user's expired equipment" do
        user = create_user(customer: @my_customer)

        EquipmentService.new.get_expired_equipment(user).should == [@my_expired_equipment]
      end
    end
  end

  describe 'get_expiring_equipment' do
    before do
      @my_customer = create_customer
      @my_expiring_equipment = create_expiring_equipment(customer: @my_customer)
      @other_expiring_equipment = create_expiring_equipment(customer: create_customer)
      @my_expired_equipment = create_expired_equipment(customer: @my_customer)
      @other_expired_equipment = create_expired_equipment(customer: create_customer)
      @my_valid_equipment = create_valid_equipment(customer: @my_customer)
      @other_valid_equipment = create_valid_equipment(customer: create_customer)
    end

    context 'sorting' do
      it 'should call Sort Service to ensure sorting' do
        equipment_service = EquipmentService.new
        fake_sort_service = equipment_service.load_sort_service(FakeSortService.new)

        equipment_service.get_expiring_equipment(create_user(customer: @my_customer))

        fake_sort_service.received_message.should == :sort
      end
    end

    context 'an admin user' do
      it 'should return all expiring equipment' do
        admin_user = create_user(roles: ['admin'])

        EquipmentService.new.get_expiring_equipment(admin_user).should == [@my_expiring_equipment, @other_expiring_equipment]
      end
    end

    context 'a regular user' do
      it "should return only that user's expiring equipment" do
        user = create_user(customer: @my_customer)

        EquipmentService.new.get_expiring_equipment(user).should == [@my_expiring_equipment]
      end
    end
  end

  describe 'get_noninspectable_equipment' do
    before do
      @my_customer = create_customer
      @my_noninspectable_equipment = create_noninspectable_equipment(customer: @my_customer)
      @other_noninspectable_equipment = create_noninspectable_equipment(customer: create_customer)
      @my_valid_equipment = create_valid_equipment(customer: @my_customer)
      @other_valid_equipment = create_valid_equipment(customer: create_customer)
    end

    context 'sorting' do
      it 'should call Sort Service to ensure sorting' do
        equipment_service = EquipmentService.new
        fake_sort_service = equipment_service.load_sort_service(FakeSortService.new)

        equipment_service.get_noninspectable_equipment(create_user(customer: @my_customer))

        fake_sort_service.received_message.should == :sort
      end
    end

    context 'an admin user' do
      it 'should return all noninspectable equipment' do
        admin_user = create_user(roles: ['admin'])

        EquipmentService.new.get_noninspectable_equipment(admin_user).should == [@my_noninspectable_equipment, @other_noninspectable_equipment]
      end
    end

    context 'a regular user' do
      it "should return only that user's noninspectable equipment" do
        user = create_user(customer: @my_customer)

        EquipmentService.new.get_noninspectable_equipment(user).should == [@my_noninspectable_equipment]
      end
    end
  end

  describe 'count_all_equipment' do
    before do
      @customer_one = create_customer
      @equipment_one = create_equipment(customer: @customer_one)
      @equipment_two = create_equipment(customer: create_customer)
    end

    context 'an admin user' do
      it 'should return count that includes all equipment' do
        admin_user = create_user(roles: ['admin'])

        EquipmentService.new.count_all_equipment(admin_user).should == 2
      end
    end

    context 'a regular user' do
      it "should return count that includes only that user's equipment" do
        user = create_user(customer: @customer_one)

        EquipmentService.new.count_all_equipment(user).should == 1
      end
    end
  end

  describe 'count_expired_equipment' do
    before do
      @customer_one = create_customer
      @customer_two = create_customer
      @valid_equipment_customer_one = create_equipment(customer: @customer_one, expiration_date: Date.today + 61.days)
      @valid_equipment_customer_two = create_equipment(customer: @customer_two, expiration_date: Date.today + 61.days)
      @expired_equipment_customer_one = create_equipment(customer: @customer_one, expiration_date: Date.yesterday)
      @expired_equipment_customer_two = create_equipment(customer: @customer_two, expiration_date: Date.yesterday)
    end

    context 'an admin user' do
      it 'should return count that includes all expired equipment' do
        admin_user = create_user(roles: ['admin'])

        EquipmentService.new.count_expired_equipment(admin_user).should == 2
      end
    end

    context 'a regular user' do
      it "should return count that includes only that user's expired equipment" do
        user = create_user(customer: @customer_one)

        EquipmentService.new.count_expired_equipment(user).should == 1
      end
    end
  end

  describe 'count_expiring_equipment' do
    before do
      @customer_one = create_customer
      @customer_two = create_customer
      @customer_three = create_customer
      @valid_equipment_customer_one = create_equipment(customer: @customer_one, expiration_date: Date.today + 61.days)
      @valid_equipment_customer_two = create_equipment(customer: @customer_two, expiration_date: Date.today + 61.days)
      @valid_equipment_customer_three = create_equipment(customer: @customer_three, expiration_date: Date.today + 61.days)
      @expiring_equipment_customer_one = create_equipment(customer: @customer_one, expiration_date: Date.tomorrow)
      @expiring_equipment_customer_two = create_equipment(customer: @customer_two, expiration_date: Date.tomorrow)
    end

    context 'an admin user' do
      it 'should return count that includes all expiring equipment' do
        admin_user = create_user(roles: ['admin'])

        EquipmentService.new.count_expiring_equipment(admin_user).should == 2
      end
    end

    context 'a regular user' do
      it "should return count that includes only that user's expiring equipment" do
        user = create_user(customer: @customer_one)

        EquipmentService.new.count_expiring_equipment(user).should == 1
      end
    end
  end

  describe 'update_equipment' do
    it 'should update equipments attributes' do
      equipment = create_equipment(customer: @customer)
      attributes =
        {
          'id' => equipment.id,
          'name' => 'Box',
          'serial_number' => 'newSN',
          'inspection_interval' => '5 years',
          'last_inspection_date' => '12/31/2001',
          'notes' => 'some new notes'
        }

      success = EquipmentService.new.update_equipment(equipment, attributes)
      success.should be_true

      equipment.reload
      equipment.name.should == 'Box'
      equipment.serial_number.should == 'newSN'
      equipment.inspection_interval.should == '5 years'
      equipment.last_inspection_date.should == Date.new(2001, 12, 31)
      equipment.inspection_type.should == InspectionType::INSPECTABLE.text
      equipment.notes.should == 'some new notes'
      equipment.expiration_date.should == Date.new(2006, 12, 31)
    end

    it 'should set inspection_interval to Non-Inspectable if interval is Not Required' do
      equipment = create_equipment(customer: @customer)
      attributes =
        {
          'id' => equipment.id,
          'inspection_interval' => 'Not Required'
        }

      success = EquipmentService.new.update_equipment(equipment, attributes)
      success.should be_true

      equipment.reload
      equipment.inspection_interval.should == 'Not Required'
      equipment.inspection_type.should == InspectionType::NON_INSPECTABLE.text
      equipment.expiration_date.should be_nil
    end

    it 'should return false if errors' do
      equipment = create_equipment(customer: @customer)
      equipment.stub(:save).and_return(false)

      success = EquipmentService.new.update_equipment(equipment, {})
      success.should be_false

      equipment.reload
      equipment.name.should_not == 'Box'
    end
  end

  describe 'create_equipment' do
    it 'should create equipment' do
      attributes =
        {
          'name' => 'Box',
          'serial_number' => 'newSN',
          'inspection_interval' => '5 years',
          'last_inspection_date' => '12/31/2001',
          'notes' => 'some new notes'
        }
      customer = new_customer

      equipment = EquipmentService.new.create_equipment(customer, attributes)

      equipment.name.should == 'Box'
      equipment.serial_number.should == 'newSN'
      equipment.inspection_interval.should == '5 years'
      equipment.last_inspection_date.should == Date.new(2001, 12, 31)
      equipment.inspection_type.should == InspectionType::INSPECTABLE.text
      equipment.notes.should == 'some new notes'
      equipment.expiration_date.should == Date.new(2006, 12, 31)
      equipment.customer.should == customer
    end

    it 'should set inspection_interval to Non-Inspectable if interval is Not Required' do
      attributes =
        {
          'name' => 'Box',
          'inspection_interval' => 'Not Required'
        }
      customer = new_customer

      equipment = EquipmentService.new.create_equipment(customer, attributes)

      equipment.name.should == 'Box'
      equipment.inspection_interval.should == 'Not Required'
      equipment.inspection_type.should == InspectionType::NON_INSPECTABLE.text
      equipment.expiration_date.should be_nil
    end
  end

  class FakeSortService
    attr_accessor :received_message

    def sort(items, sort_field, sort_direction)
      @received_message = :sort
      []
    end
  end
end