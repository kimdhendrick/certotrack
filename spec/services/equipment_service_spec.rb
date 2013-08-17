require 'spec_helper'

describe EquipmentService do
  describe 'get_all_equipment' do
    before do
      @my_customer = create_customer
      @my_user = create_user(customer: @my_customer)
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

      context 'sorting' do
        it 'should sort by name ascending by default' do
          create_equipment(name: 'zeta', customer: @my_customer)
          create_equipment(name: 'beta', customer: @my_customer)
          create_equipment(name: 'alpha', customer: @my_customer)

          EquipmentService.new.get_all_equipment(@my_user).map(&:name).should ==
            ['alpha', 'beta', 'zeta']
        end

        it 'should sort by name ascending' do
          create_equipment(name: 'zeta', customer: @my_customer)
          create_equipment(name: 'beta', customer: @my_customer)
          create_equipment(name: 'alpha', customer: @my_customer)

          params = {
            sort: 'name',
            direction: 'asc'
          }

          EquipmentService.new.get_all_equipment(@my_user, params).map(&:name).should ==
            ['alpha', 'beta', 'zeta']
        end

        it 'should sort by name descending' do
          create_equipment(name: 'zeta', customer: @my_customer)
          create_equipment(name: 'beta', customer: @my_customer)
          create_equipment(name: 'alpha', customer: @my_customer)

          params = {
            sort: 'name',
            direction: 'desc'
          }

          EquipmentService.new.get_all_equipment(@my_user, params).map(&:name).should ==
            ['zeta', 'beta', 'alpha']
        end

        it 'should sort by serial_number ascending' do
          create_equipment(serial_number: '222', customer: @my_customer)
          create_equipment(serial_number: '333', customer: @my_customer)
          create_equipment(serial_number: '111', customer: @my_customer)

          params = {
            sort: 'serial_number',
            direction: 'asc'
          }

          EquipmentService.new.get_all_equipment(@my_user, params).map(&:serial_number).should ==
            ['111', '222', '333']
        end

        it 'should sort by serial_number descending' do
          create_equipment(serial_number: '222', customer: @my_customer)
          create_equipment(serial_number: '333', customer: @my_customer)
          create_equipment(serial_number: '111', customer: @my_customer)

          params = {
            sort: 'serial_number',
            direction: 'desc'
          }

          EquipmentService.new.get_all_equipment(@my_user, params).map(&:serial_number).should ==
            ['333', '222', '111']
        end

        it 'should sort by status ascending' do
          create_expiring_equipment(customer: @my_customer)
          create_expired_equipment(customer: @my_customer)
          create_valid_equipment(customer: @my_customer)

          params = {
            sort: 'status_code',
            direction: 'asc'
          }

          EquipmentService.new.get_all_equipment(@my_user, params).map(&:status).should ==
            [Status::VALID, Status::EXPIRING, Status::EXPIRED]
        end

        it 'should sort by status descending' do
          create_expiring_equipment(customer: @my_customer)
          create_expired_equipment(customer: @my_customer)
          create_valid_equipment(customer: @my_customer)

          params = {
            sort: 'status_code',
            direction: 'desc'
          }

          EquipmentService.new.get_all_equipment(@my_user, params).map(&:status).should ==
            [Status::EXPIRED, Status::EXPIRING, Status::VALID]
        end

        it 'should sort by inspection_interval ascending' do
          create_equipment(inspection_interval: InspectionInterval::SIX_MONTHS.text, customer: @my_customer)
          create_equipment(inspection_interval: InspectionInterval::TWO_YEARS.text, customer: @my_customer)
          create_equipment(inspection_interval: InspectionInterval::ONE_YEAR.text, customer: @my_customer)
          create_equipment(inspection_interval: InspectionInterval::FIVE_YEARS.text, customer: @my_customer)
          create_equipment(inspection_interval: InspectionInterval::NOT_REQUIRED.text, customer: @my_customer)
          create_equipment(inspection_interval: InspectionInterval::THREE_YEARS.text, customer: @my_customer)
          create_equipment(inspection_interval: InspectionInterval::ONE_MONTH.text, customer: @my_customer)
          create_equipment(inspection_interval: InspectionInterval::THREE_MONTHS.text, customer: @my_customer)

          params = {
            sort: 'inspection_interval_code',
            direction: 'asc'
          }

          EquipmentService.new.get_all_equipment(@my_user, params).map(&:inspection_interval).should ==
            [
              InspectionInterval::ONE_MONTH.text,
              InspectionInterval::THREE_MONTHS.text,
              InspectionInterval::SIX_MONTHS.text,
              InspectionInterval::ONE_YEAR.text,
              InspectionInterval::TWO_YEARS.text,
              InspectionInterval::THREE_YEARS.text,
              InspectionInterval::FIVE_YEARS.text,
              InspectionInterval::NOT_REQUIRED.text
            ]
        end

        it 'should sort by inspection_interval descending' do
          create_equipment(inspection_interval: InspectionInterval::SIX_MONTHS.text, customer: @my_customer)
          create_equipment(inspection_interval: InspectionInterval::TWO_YEARS.text, customer: @my_customer)
          create_equipment(inspection_interval: InspectionInterval::ONE_YEAR.text, customer: @my_customer)
          create_equipment(inspection_interval: InspectionInterval::FIVE_YEARS.text, customer: @my_customer)
          create_equipment(inspection_interval: InspectionInterval::NOT_REQUIRED.text, customer: @my_customer)
          create_equipment(inspection_interval: InspectionInterval::THREE_YEARS.text, customer: @my_customer)
          create_equipment(inspection_interval: InspectionInterval::ONE_MONTH.text, customer: @my_customer)
          create_equipment(inspection_interval: InspectionInterval::THREE_MONTHS.text, customer: @my_customer)

          params = {
            sort: 'inspection_interval_code',
            direction: 'desc'
          }

          EquipmentService.new.get_all_equipment(@my_user, params).map(&:inspection_interval).should ==
            [
              InspectionInterval::NOT_REQUIRED.text,
              InspectionInterval::FIVE_YEARS.text,
              InspectionInterval::THREE_YEARS.text,
              InspectionInterval::TWO_YEARS.text,
              InspectionInterval::ONE_YEAR.text,
              InspectionInterval::SIX_MONTHS.text,
              InspectionInterval::THREE_MONTHS.text,
              InspectionInterval::ONE_MONTH.text
            ]
        end

        it 'should sort by last_inspection_date ascending' do
          middle_date = Date.new(2013, 6, 15)
          latest_date = Date.new(2013, 12, 31)
          earliest_date = Date.new(2013, 1, 1)

          create_equipment(last_inspection_date: middle_date, customer: @my_customer)
          create_equipment(last_inspection_date: latest_date, customer: @my_customer)
          create_equipment(last_inspection_date: earliest_date, customer: @my_customer)

          params = {
            sort: 'last_inspection_date',
            direction: 'asc'
          }

          EquipmentService.new.get_all_equipment(@my_user, params).map(&:last_inspection_date).should ==
            [earliest_date, middle_date, latest_date]
        end

        it 'should sort by last_inspection_date descending' do
          middle_date = Date.new(2013, 6, 15)
          latest_date = Date.new(2013, 12, 31)
          earliest_date = Date.new(2013, 1, 1)

          create_equipment(last_inspection_date: middle_date, customer: @my_customer)
          create_equipment(last_inspection_date: latest_date, customer: @my_customer)
          create_equipment(last_inspection_date: earliest_date, customer: @my_customer)

          params = {
            sort: 'last_inspection_date',
            direction: 'desc'
          }

          EquipmentService.new.get_all_equipment(@my_user, params).map(&:last_inspection_date).should ==
            [latest_date, middle_date, earliest_date]
        end

        it 'should sort by inspection_type ascending' do
          inspectable1 = create_equipment(inspection_interval: InspectionInterval::ONE_YEAR.text, customer: @my_customer)
          not_inspectable = create_equipment(inspection_interval: InspectionInterval::NOT_REQUIRED.text, customer: @my_customer)
          inspectable2 = create_equipment(inspection_interval: InspectionInterval::FIVE_YEARS.text, customer: @my_customer)

          params = {
            sort: 'inspection_type',
            direction: 'asc'
          }

          EquipmentService.new.get_all_equipment(@my_user, params).map(&:inspection_type).should ==
            ["Inspectable", "Inspectable", "Non-Inspectable"]
        end

        it 'should sort by inspection_type descending' do
          create_equipment(inspection_interval: InspectionInterval::ONE_YEAR.text, customer: @my_customer)
          create_equipment(inspection_interval: InspectionInterval::NOT_REQUIRED.text, customer: @my_customer)
          create_equipment(inspection_interval: InspectionInterval::FIVE_YEARS.text, customer: @my_customer)

          params = {
            sort: 'inspection_type',
            direction: 'desc'
          }

          EquipmentService.new.get_all_equipment(@my_user, params).map(&:inspection_type).should ==
            ["Non-Inspectable", "Inspectable", "Inspectable"]
        end

        # expiration date
        it 'should sort by expiration_date ascending' do
          middle_date = Date.new(2013, 6, 15)
          latest_date = Date.new(2013, 12, 31)
          earliest_date = Date.new(2013, 1, 1)

          create_equipment(expiration_date: middle_date, customer: @my_customer)
          create_equipment(expiration_date: latest_date, customer: @my_customer)
          create_equipment(expiration_date: earliest_date, customer: @my_customer)

          params = {
            sort: 'expiration_date',
            direction: 'asc'
          }

          EquipmentService.new.get_all_equipment(@my_user, params).map(&:expiration_date).should ==
            [earliest_date, middle_date, latest_date]
        end

        it 'should sort by expiration_date descending' do
          middle_date = Date.new(2013, 6, 15)
          latest_date = Date.new(2013, 12, 31)
          earliest_date = Date.new(2013, 1, 1)

          create_equipment(expiration_date: middle_date, customer: @my_customer)
          create_equipment(expiration_date: latest_date, customer: @my_customer)
          create_equipment(expiration_date: earliest_date, customer: @my_customer)

          params = {
            sort: 'expiration_date',
            direction: 'desc'
          }

          EquipmentService.new.get_all_equipment(@my_user, params).map(&:expiration_date).should ==
            [latest_date, middle_date, earliest_date]
        end

        it 'should sort by assignee ascending' do
          middle_employee = create_employee(first_name: 'Bob', last_name: 'Baker')
          first_employee = create_employee(first_name: 'Albert', last_name: 'Alfonso')
          last_employee = create_employee(first_name: 'Zoe', last_name: 'Zephyr')

          first_location = create_location(name: 'Alcatraz')
          last_location = create_location(name: 'Zurich')
          middle_location = create_location(name: 'Burbank')

          create_equipment(employee: middle_employee, customer: @my_customer)
          create_equipment(location: last_location, customer: @my_customer)
          create_equipment(location: first_location, customer: @my_customer)
          create_equipment(employee: last_employee, customer: @my_customer)
          create_equipment(employee: first_employee, customer: @my_customer)
          create_equipment(location: middle_location, customer: @my_customer)

          params = {
            sort: 'assignee',
            direction: 'asc'
          }

          EquipmentService.new.get_all_equipment(@my_user, params).map(&:assignee).should ==
            ['Alcatraz', 'Alfonso, Albert', 'Baker, Bob', 'Burbank', 'Zephyr, Zoe', 'Zurich']
        end

        it 'should sort by assignee descending' do
          middle_employee = create_employee(first_name: 'Bob', last_name: 'Baker')
          first_employee = create_employee(first_name: 'Albert', last_name: 'Alfonso')
          last_employee = create_employee(first_name: 'Zoe', last_name: 'Zephyr')

          first_location = create_location(name: 'Alcatraz')
          last_location = create_location(name: 'Zurich')
          middle_location = create_location(name: 'Burbank')

          create_equipment(employee: middle_employee, customer: @my_customer)
          create_equipment(location: last_location, customer: @my_customer)
          create_equipment(location: first_location, customer: @my_customer)
          create_equipment(employee: last_employee, customer: @my_customer)
          create_equipment(employee: first_employee, customer: @my_customer)
          create_equipment(location: middle_location, customer: @my_customer)

          params = {
            sort: 'assignee',
            direction: 'desc'
          }

          EquipmentService.new.get_all_equipment(@my_user, params).map(&:assignee).should ==
            ['Zurich', 'Zephyr, Zoe', 'Burbank', 'Baker, Bob', 'Alfonso, Albert', 'Alcatraz']
        end
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
end