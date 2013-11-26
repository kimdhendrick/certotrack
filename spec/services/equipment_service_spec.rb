require 'spec_helper'

describe EquipmentService do
  let(:my_customer) { create(:customer) }
  let(:my_user) { create(:user, customer: my_customer) }
  let(:admin_user) { create(:user, roles: ['admin']) }

  describe 'get_all_equipment' do
    context 'an admin user' do
      it 'should return all equipment' do
        my_equipment = create(:equipment, customer: my_customer)
        other_equipment = create(:equipment)

        EquipmentService.new.get_all_equipment(admin_user).should == [my_equipment, other_equipment]
      end
    end

    context 'a regular user' do
      it "should return only that user's equipment" do
        my_equipment = create(:equipment, customer: my_customer)
        other_equipment = create(:equipment)

        EquipmentService.new.get_all_equipment(my_user).should == [my_equipment]
      end
    end
  end

  describe 'search_equipment' do
    context 'search' do
      it 'should call SearchService to filter results' do
        fake_search_service = Faker.new
        equipment_service = EquipmentService.new(search_service: fake_search_service)

        equipment_service.search_equipment(my_user, {thing1: 'thing2'})

        fake_search_service.received_message.should == :search
        fake_search_service.received_params[0].should == []
        fake_search_service.received_params[1].should == {thing1: 'thing2'}
      end
    end

    context 'an admin user' do
      it 'should return all equipment' do
        my_equipment = create(:equipment, customer: my_customer)
        other_equipment = create(:equipment)

        EquipmentService.new.search_equipment(admin_user, {}).should == [my_equipment, other_equipment]
      end
    end

    context 'a regular user' do
      it "should return only that user's equipment" do
        my_equipment = create(:equipment, customer: my_customer)
        other_equipment = create(:equipment)

        EquipmentService.new.search_equipment(my_user, {}).should == [my_equipment]
      end
    end
  end

  describe 'get_expired_equipment' do
    let!(:my_expired_equipment) { create(:expired_equipment, customer: my_customer) }
    let!(:other_expired_equipment) { create(:expired_equipment) }
    let!(:my_valid_equipment) { create(:valid_equipment, customer: my_customer) }
    let!(:other_valid_equipment) { create(:valid_equipment) }
    let!(:my_expiring_equipment) { create(:expiring_equipment, customer: my_customer) }
    let!(:other_expiring_equipment) { create(:expiring_equipment) }

    context 'an admin user' do
      it 'should return all expired equipment' do
        EquipmentService.new.get_expired_equipment(admin_user).should == [my_expired_equipment, other_expired_equipment]
      end
    end

    context 'a regular user' do
      it "should return only that user's expired equipment" do
        EquipmentService.new.get_expired_equipment(my_user).should == [my_expired_equipment]
      end
    end
  end

  describe 'get_expiring_equipment' do
    let!(:my_expiring_equipment) { create(:expiring_equipment, customer: my_customer) }
    let!(:other_expiring_equipment) { create(:expiring_equipment) }
    let!(:my_expired_equipment) { create(:expired_equipment, customer: my_customer) }
    let!(:other_expired_equipment) { create(:expired_equipment) }
    let!(:my_valid_equipment) { create(:valid_equipment, customer: my_customer) }
    let!(:other_valid_equipment) { create(:valid_equipment) }

    context 'an admin user' do
      it 'should return all expiring equipment' do
        EquipmentService.new.get_expiring_equipment(admin_user).should == [my_expiring_equipment, other_expiring_equipment]
      end
    end

    context 'a regular user' do
      it "should return only that user's expiring equipment" do
        EquipmentService.new.get_expiring_equipment(my_user).should == [my_expiring_equipment]
      end
    end
  end

  describe 'get_noninspectable_equipment' do
    let!(:my_noninspectable_equipment) { create(:noninspectable_equipment, customer: my_customer) }
    let!(:other_noninspectable_equipment) { create(:noninspectable_equipment) }
    let!(:my_valid_equipment) { create(:valid_equipment, customer: my_customer) }
    let!(:other_valid_equipment) { create(:valid_equipment) }

    context 'an admin user' do
      it 'should return all noninspectable equipment' do
        EquipmentService.new.get_noninspectable_equipment(admin_user).should == [my_noninspectable_equipment, other_noninspectable_equipment]
      end
    end

    context 'a regular user' do
      it "should return only that user's noninspectable equipment" do
        EquipmentService.new.get_noninspectable_equipment(my_user).should == [my_noninspectable_equipment]
      end
    end
  end

  describe 'count_all_equipment' do
    let(:customer_one) { create(:customer) }
    before do
      equipment_one = create(:equipment, customer: customer_one)
      equipment_two = create(:equipment)
    end

    context 'an admin user' do
      it 'should return count that includes all equipment' do
        EquipmentService.new.count_all_equipment(admin_user).should == 2
      end
    end

    context 'a regular user' do
      it "should return count that includes only that user's equipment" do
        user = create(:user, customer: customer_one)

        EquipmentService.new.count_all_equipment(user).should == 1
      end
    end
  end

  describe 'count_expired_equipment' do
    let(:customer_one) { create(:customer) }

    before do
      customer_two = create(:customer)
      valid_equipment_customer_one = create(:equipment, customer: customer_one, expiration_date: Date.today + 61.days)
      valid_equipment_customer_two = create(:equipment, customer: customer_two, expiration_date: Date.today + 61.days)
      expired_equipment_customer_one = create(:equipment, customer: customer_one, expiration_date: Date.yesterday)
      expired_equipment_customer_two = create(:equipment, customer: customer_two, expiration_date: Date.yesterday)
    end

    context 'an admin user' do
      it 'should return count that includes all expired equipment' do
        EquipmentService.new.count_expired_equipment(admin_user).should == 2
      end
    end

    context 'a regular user' do
      it "should return count that includes only that user's expired equipment" do
        user = create(:user, customer: customer_one)

        EquipmentService.new.count_expired_equipment(user).should == 1
      end
    end
  end

  describe 'count_expiring_equipment' do
    let(:customer_one) { create(:customer) }

    before do
      customer_two = create(:customer)
      customer_three = create(:customer)
      valid_equipment_customer_one = create(:equipment, customer: customer_one, expiration_date: Date.today + 61.days)
      valid_equipment_customer_two = create(:equipment, customer: customer_two, expiration_date: Date.today + 61.days)
      valid_equipment_customer_three = create(:equipment, customer: customer_three, expiration_date: Date.today + 61.days)
      expiring_equipment_customer_one = create(:equipment, customer: customer_one, expiration_date: Date.tomorrow)
      expiring_equipment_customer_two = create(:equipment, customer: customer_two, expiration_date: Date.tomorrow)
    end

    context 'an admin user' do
      it 'should return count that includes all expiring equipment' do
        EquipmentService.new.count_expiring_equipment(admin_user).should == 2
      end
    end

    context 'a regular user' do
      it "should return count that includes only that user's expiring equipment" do
        user = create(:user, customer: customer_one)

        EquipmentService.new.count_expiring_equipment(user).should == 1
      end
    end
  end

  describe 'update_equipment' do
    it 'should update equipments attributes' do
      equipment = create(:equipment, customer: my_customer)
      attributes =
        {
          'id' => equipment.id,
          'name' => 'Box',
          'serial_number' => 'newSN',
          'inspection_interval' => '5 years',
          'last_inspection_date' => '12/31/2001',
          'comments' => 'some new notes'
        }

      success = EquipmentService.new.update_equipment(equipment, attributes)
      success.should be_true

      equipment.reload
      equipment.name.should == 'Box'
      equipment.serial_number.should == 'newSN'
      equipment.inspection_interval.should == '5 years'
      equipment.last_inspection_date.should == Date.new(2001, 12, 31)
      equipment.inspection_type.should == InspectionType::INSPECTABLE.text
      equipment.comments.should == 'some new notes'
      equipment.expiration_date.should == Date.new(2006, 12, 31)
    end

    it 'should set inspection_interval to Non-Inspectable if interval is Not Required' do
      equipment = create(:equipment, customer: my_customer)
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
      equipment = create(:equipment, customer: my_customer)
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
          'comments' => 'some new notes'
        }
      customer = build(:customer)

      equipment = EquipmentService.new.create_equipment(customer, attributes)

      equipment.should be_persisted
      equipment.name.should == 'Box'
      equipment.serial_number.should == 'newSN'
      equipment.inspection_interval.should == '5 years'
      equipment.last_inspection_date.should == Date.new(2001, 12, 31)
      equipment.inspection_type.should == InspectionType::INSPECTABLE.text
      equipment.comments.should == 'some new notes'
      equipment.expiration_date.should == Date.new(2006, 12, 31)
      equipment.customer.should == customer
    end

    it 'should set inspection_interval to Non-Inspectable if interval is Not Required' do
      attributes =
        {
          'name' => 'Box',
          'inspection_interval' => 'Not Required',
          'serial_number' => 'newSN'
        }
      customer = build(:customer)

      equipment = EquipmentService.new.create_equipment(customer, attributes)

      equipment.name.should == 'Box'
      equipment.inspection_interval.should == 'Not Required'
      equipment.inspection_type.should == InspectionType::NON_INSPECTABLE.text
      equipment.expiration_date.should be_nil
    end
  end

  describe 'delete_equipment' do
    it 'destroys the requested equipment' do
      equipment = create(:equipment, customer: my_customer)

      expect {
        EquipmentService.new.delete_equipment(equipment)
      }.to change(Equipment, :count).by(-1)
    end
  end

  describe 'get_all_equipment_for_employee' do
    it 'returns only equipment assigned to employee' do
      employee = create(:employee)
      assigned_equipment = create(:equipment, employee: employee)
      unassigned_equipment = create(:equipment, employee: nil)

      EquipmentService.new.get_all_equipment_for_employee(employee).should == [assigned_equipment]
    end
  end

  describe 'get_equipment_names' do
    it "should only return own customer's equipment names" do
      my_customer = create(:customer)
      me = create(:user, customer: my_customer)
      create(:equipment, name: 'my_equipment', customer: my_customer)
      create(:equipment, name: 'not_my_equipment', customer: create(:customer))

      EquipmentService.new.get_equipment_names(me, 'equipment').should == ['my_equipment']
    end

    it 'should not return duplicate names' do
      my_customer = create(:customer)
      me = create(:user, customer: my_customer)
      create(:equipment, name: 'my_equipment', customer: my_customer)
      create(:equipment, name: 'my_equipment', customer: my_customer)

      EquipmentService.new.get_equipment_names(me, 'equipment').should == ['my_equipment']
    end

    it 'should match term anywhere in name' do
      my_customer = create(:customer)
      me = create(:user, customer: my_customer)
      create(:equipment, name: 'equipment_end', customer: my_customer)
      create(:equipment, name: 'beginning_equipment_end', customer: my_customer)
      create(:equipment, name: 'beginning_equipment', customer: my_customer)

      EquipmentService.new.get_equipment_names(me, 'equipment').should =~
        ['equipment_end', 'beginning_equipment_end', 'beginning_equipment']
    end
  end

  describe 'performance testing of sorting' do
    it 'should time the sorting of equipment' do

      # Test results as of 2013-08-18 15:42:08 -0600:
      # 1,000...
      # Time elapsed: 0.003632 (for name)
      # Time elapsed: 0.00291 (for serial_number)
      # Time elapsed: 0.010663 (for status_code)
      # Time elapsed: 0.007275 (for inspection_interval_code)
      # Time elapsed: 0.003812 (for last_inspection_date)
      # Time elapsed: 0.001077 (for expiration_date)
      # Time elapsed: 0.024727 (for assignee)
      # Average: 0.007728 (1,000)
      # 10,000...
      # Time elapsed: 0.034225 (for name)
      # Time elapsed: 0.039557 (for serial_number)
      # Time elapsed: 0.1305 (for status_code)
      # Time elapsed: 0.106152 (for inspection_interval_code)
      # Time elapsed: 0.079333 (for last_inspection_date)
      # Time elapsed: 0.031203 (for expiration_date)
      # Time elapsed: 0.643867 (for assignee)
      # Average: 0.1521195714285714 (10,000)
      # 100,000...
      # Time elapsed: 0.487783 (for name)
      # Time elapsed: 0.795771 (for serial_number)
      # Time elapsed: 1.276033 (for status_code)
      # Time elapsed: 1.338913 (for inspection_interval_code)
      # Time elapsed: 0.564061 (for last_inspection_date)
      # Time elapsed: 0.221214 (for expiration_date)
      # Time elapsed: 6.174405 (for assignee)
      # Average: 1.5511685714285715 (100,000)

      ###########################################
      # Uncomment for performance testing
      ###########################################

      #puts "Test results as of #{Time::now}:"
      #
      #equipment = []
      #100000.times do
      #  equipment << new_equipment(expiration_date: Date.new(2013, 1, 2), customer: my_customer)
      #end
      #
      #sorter = Sorter.new
      #
      #puts "1,000..."
      #field_list = ['name', 'serial_number', 'status_code',
      #              'inspection_interval_code', 'last_inspection_date',
      #              'expiration_date', 'assignee']
      #
      #total = 0
      #field_list.each do |field|
      #  total += _sort_fields(sorter, equipment[0..999], field)
      #end
      #puts "Average: #{total/field_list.count} (1,000)"
      #
      #puts "10,000..."
      #total = 0
      #field_list.each do |field|
      #  total += _sort_fields(sorter, equipment[0..9999], field)
      #end
      #puts "Average: #{total/field_list.count} (10,000)"
      #
      #puts "100,000..."
      #total = 0
      #field_list.each do |field|
      #  total += _sort_fields(sorter, equipment, field)
      #end
      #puts "Average: #{total/field_list.count} (100,000)"
    end
  end

  #def _sort_fields(sorter, equipment, field)
  #  start = Time::now
  #  sorter.sort(equipment, field, 'asc')
  #  elapsed = Time::now-start
  #  puts "Time elapsed: #{elapsed} (for #{field})"
  #  elapsed
  #end
end
