require 'spec_helper'

describe 'Equipment', js: true do

  describe 'Show Equipment' do
    before do
      login_as_equipment_user
      @denver_location = create_location(name: 'Denver', customer_id: @customer.id)
      @littleton_location = create_location(name: 'Littleton', customer_id: @customer.id)
    end

    it 'should render equipment show page' do
      valid_equipment = create_equipment(
        customer: @customer,
        name: 'Meter',
        serial_number: 'ABC123',
        inspection_interval: 'Annually',
        last_inspection_date: Date.new(2013, 1, 1),
        expiration_date: Date.new(2024, 2, 3),
        notes: 'my notes',
        location_id: @denver_location.id
      )

      visit '/'
      click_link 'All Equipment'
      click_link 'Meter'

      page.should have_content 'Show Equipment'
      page.should have_link 'Home'
      page.should have_link 'All Equipment'
      page.should have_link 'Create Equipment'

      page.should have_content 'Name'
      page.should have_content 'Serial Number'
      page.should have_content 'Status'
      page.should have_content 'Location'
      page.should have_content 'Inspection Interval'
      page.should have_content 'Last Inspection Date'
      page.should have_content 'Expiration Date'
      page.should have_content 'Comments'

      page.should have_content 'Meter'
      page.should have_content 'ABC123'
      page.should have_content 'Denver'
      page.should have_content 'Valid'
      page.should have_content 'Annually'
      page.should have_content '01/01/2013'
      page.should have_content '02/03/2024'
      page.should have_content 'my notes'

      page.should have_link 'Edit'
      page.should have_link 'Delete'
    end
  end

  describe 'Create Equipment' do
    before do
      login_as_equipment_user
      @denver_location = create_location(name: 'Denver', customer_id: @customer.id)
      @littleton_location = create_location(name: 'Littleton', customer_id: @customer.id)
      @special_employee = create_employee(first_name: 'Special', last_name: 'Employee', customer_id: @customer.id)
    end

    it 'should create new equipment assigned to a location' do
      visit '/'
      click_link 'Create Equipment'

      page.should have_content 'Create Equipment'
      page.should have_link 'Home'

      page.should have_content 'Name'
      page.should have_content 'Serial Number'
      page.should have_content 'Assignee'
      page.should have_content 'Inspection Interval'
      page.should have_content 'Last Inspection Date'
      page.should have_content 'Comments'

      fill_in 'Name', with: 'Level'
      fill_in 'Serial Number', with: '765-CKD'
      select 'Location', from: 'Assignee'
      find '#assignedTo'
      select 'Littleton', from: 'assignedTo'
      select '5 years', from: 'Inspection Interval'
      fill_in 'Last Inspection Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Equipment'
      page.should have_content 'Equipment was successfully created.'

      page.should have_content 'Level'
      page.should have_content '765-CKD'
      page.should have_content 'Littleton'
      page.should have_content 'Expired'
      page.should have_content '5 years'
      page.should have_content '01/01/2000'
      page.should have_content '01/01/2005'
      page.should have_content 'Special Notes'
    end

    it 'should create new equipment assigned to an employee' do
      visit '/'
      click_link 'Create Equipment'

      page.should have_content 'Create Equipment'
      page.should have_link 'Home'
      page.should have_link 'Search Equipment'

      page.should have_content 'Name'
      page.should have_content 'Serial Number'
      page.should have_content 'Assignee'
      page.should have_content 'Inspection Interval'
      page.should have_content 'Last Inspection Date'
      page.should have_content 'Comments'

      fill_in 'Name', with: 'Level'
      fill_in 'Serial Number', with: '765-CKD'
      select 'Employee', from: 'Assignee'
      find '#assignedTo'
      select 'Employee, Special', from: 'assignedTo'
      select '5 years', from: 'Inspection Interval'
      fill_in 'Last Inspection Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Equipment'
      page.should have_content 'Equipment was successfully created.'

      page.should have_content 'Level'
      page.should have_content '765-CKD'
      page.should have_content 'Employee, Special'
      page.should have_content 'Expired'
      page.should have_content '5 years'
      page.should have_content '01/01/2000'
      page.should have_content '01/01/2005'
      page.should have_content 'Special Notes'
    end

    it 'should create new unassigned equipment' do
      visit '/'
      click_link 'Create Equipment'

      page.should have_content 'Create Equipment'
      page.should have_link 'Home'

      page.should have_content 'Name'
      page.should have_content 'Serial Number'
      page.should have_content 'Assignee'
      page.should have_content 'Inspection Interval'
      page.should have_content 'Last Inspection Date'
      page.should have_content 'Comments'

      fill_in 'Name', with: 'Level'
      fill_in 'Serial Number', with: '765-CKD'
      select '5 years', from: 'Inspection Interval'
      fill_in 'Last Inspection Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Equipment'
      page.should have_content 'Equipment was successfully created.'

      page.should have_content 'Level'
      page.should have_content '765-CKD'
      page.should have_content 'Unassigned'
      page.should have_content 'Expired'
      page.should have_content '5 years'
      page.should have_content '01/01/2000'
      page.should have_content '01/01/2005'
      page.should have_content 'Special Notes'
    end

    it 'should alert on future dates' do
      visit '/'
      click_link 'Create Equipment'

      fill_in 'Name', with: 'Level'
      fill_in 'Serial Number', with: '765-CKD-123'
      fill_in 'Last Inspection Date', with: '01/01/2055'

      click_on 'Create'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to enter a future date?')
      alert.dismiss

      fill_in 'Last Inspection Date', with: '01/01/2000'

      click_on 'Create'

      page.should have_content 'Show Equipment'
      page.should have_content '01/01/2000'

      visit '/'
      click_link 'Create Equipment'

      fill_in 'Name', with: 'Level'
      fill_in 'Serial Number', with: '765-CKD-456'
      fill_in 'Last Inspection Date', with: '01/01/2055'

      click_on 'Create'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to enter a future date?')
      alert.accept

      page.should have_content 'Show Equipment'
      page.should have_content 'Equipment was successfully created.'
      page.should have_content '01/01/2055'
    end

  end

  describe 'Update Equipment' do
    before do
      login_as_equipment_user
      @denver_location = create_location(name: 'Denver', customer_id: @customer.id)
      @littleton_location = create_location(name: 'Littleton', customer_id: @customer.id)
      @special_employee = create_employee(first_name: 'Special', last_name: 'Employee', customer_id: @customer.id)
    end

    it 'should update existing equipment' do
      valid_equipment = create_equipment(
        customer: @customer,
        name: 'Meter',
        serial_number: 'ABC123',
        inspection_interval: 'Annually',
        last_inspection_date: Date.new(2013, 1, 1),
        expiration_date: Date.new(2024, 2, 3),
        notes: 'my notes',
        location_id: @littleton_location.id
      )

      visit '/'
      click_link 'All Equipment'
      click_link 'Meter'

      page.should have_content 'Show Equipment'
      click_on 'Edit'

      page.should have_content 'Edit Equipment'
      page.should have_link 'Home'
      page.should have_link 'All Equipment'
      page.should have_link 'Create Equipment'

      page.should have_content 'Name'
      page.should have_content 'Serial Number'
      page.should have_content 'Assignee'
      page.should have_content 'Location'
      page.should have_content 'Inspection Interval'
      page.should have_content 'Last Inspection Date'
      page.should have_content 'Comments'

      page.should have_link 'Delete'

      fill_in 'Name', with: 'Level'
      fill_in 'Serial Number', with: '765-CKD'

      select 'Employee', from: 'Assignee'
      find '#assignedTo'
      select 'Employee, Special', from: 'assignedTo'
      select '5 years', from: 'Inspection Interval'
      fill_in 'Last Inspection Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Update'

      page.should have_content 'Show Equipment'
      page.should have_content 'Equipment was successfully updated.'

      page.should have_content 'Level'
      page.should have_content '765-CKD'
      page.should have_content 'Employee, Special'
      page.should have_content 'Expired'
      page.should have_content '5 years'
      page.should have_content '01/01/2000'
      page.should have_content '01/01/2005'
      page.should have_content 'Special Notes'
    end

    it 'should alert on future dates' do
      valid_equipment = create_equipment(
        customer: @customer,
        name: 'Meter',
        serial_number: 'ABC123',
        inspection_interval: 'Annually',
        last_inspection_date: Date.new(2013, 1, 1),
        expiration_date: Date.new(2024, 2, 3),
        notes: 'my notes',
        location_id: @littleton_location.id
      )

      visit '/'
      click_link 'All Equipment'
      click_link 'Meter'
      click_on 'Edit'

      fill_in 'Last Inspection Date', with: '01/01/2055'

      click_on 'Update'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to enter a future date?')
      alert.dismiss

      fill_in 'Last Inspection Date', with: '01/01/2000'

      click_on 'Update'

      page.should have_content 'Show Equipment'
      page.should have_content '01/01/2000'

      visit '/'
      click_link 'All Equipment'
      click_link 'Meter'
      click_link 'Edit'

      fill_in 'Last Inspection Date', with: '01/01/2055'

      click_on 'Update'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to enter a future date?')
      alert.accept

      page.should have_content 'Show Equipment'
      page.should have_content 'Equipment was successfully updated.'
      page.should have_content '01/01/2055'
    end
  end

  describe 'Delete Equipment' do
    before do
      login_as_equipment_user
      @denver_location = create_location(name: 'Denver', customer_id: @customer.id)
    end

    it 'should delete existing equipment' do
      valid_equipment = create_equipment(
        customer: @customer,
        name: 'Meter'
      )

      visit '/'
      click_link 'All Equipment'
      click_link 'Meter'

      page.should have_content 'Show Equipment'
      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete?')
      alert.dismiss

      page.should have_content 'Show Equipment'

      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete?')
      alert.accept

      page.should have_content 'All Equipment'
      page.should have_content 'Equipment was successfully deleted.'
    end
  end

  describe 'Reports' do
    context 'when an equipment user' do
      before do
        login_as_equipment_user
        @denver_location = create_location(name: 'Denver', customer_id: @customer.id)
        @littleton_location = create_location(name: 'Littleton', customer_id: @customer.id)
        @special_employee = create_employee(first_name: 'Special', last_name: 'Employee', customer_id: @customer.id)
      end

      it 'should show All Equipment report' do
        create_equipment(
          customer: @customer,
          name: 'Meter',
          serial_number: 'ABC123',
          inspection_interval: 'Annually',
          last_inspection_date: Date.new(2013, 1, 1),
          expiration_date: Date.new(2024, 2, 3),
          employee_id: @special_employee.id
        )

        create_equipment(
          customer: @customer,
          name: 'Box',
          serial_number: 'BBB999',
          inspection_interval: 'Annually',
          last_inspection_date: Date.new(2012, 1, 1),
          expiration_date: Date.new(2013, 1, 1),
          location_id: @denver_location.id
        )

        visit '/'
        page.should have_content 'All Equipment'
        click_link 'All Equipment'

        page.should have_content 'All Equipment'
        page.should have_content 'Total: 2'
        page.should have_link 'Home'
        page.should have_link 'Create Equipment'

        assert_report_headers_are_correct

        within 'table tbody tr:nth-of-type(1)' do
          page.should have_link 'Box'
          page.should have_content 'BBB999'
          page.should have_content 'Expired'
          page.should have_content 'Annually'
          page.should have_content '01/01/2012'
          page.should have_content 'Inspectable'
          page.should have_content '01/01/2013'
          page.should have_content 'Denver'
        end

        within 'table tbody tr:nth-of-type(2)' do
          page.should have_link 'Meter'
          page.should have_content 'ABC123'
          page.should have_content 'Valid'
          page.should have_content 'Annually'
          page.should have_content '01/01/2013'
          page.should have_content 'Inspectable'
          page.should have_content '02/03/2024'
          page.should have_content 'Employee, Special'
        end
      end

      it 'should show Expired Equipment report' do
        expired_equipment = create_equipment(
          customer: @customer,
          name: 'Gauge',
          serial_number: 'XYZ987',
          inspection_interval: Interval::ONE_MONTH.text,
          last_inspection_date: Date.new(2011, 12, 5),
          expiration_date: Date.new(2012, 7, 11),
          location_id: @littleton_location.id
        )

        visit '/'
        page.should have_content 'Expired Equipment'
        click_link 'Expired Equipment'

        page.should have_content 'Expired Equipment List'
        page.should have_content 'Total: 1'
        page.should have_link 'Home'
        page.should have_link 'Create Equipment'

        assert_report_headers_are_correct

        within 'tbody tr', text: 'Gauge' do
          page.should have_link 'Gauge'
          page.should have_content 'XYZ987'
          page.should have_content 'Expired'
          page.should have_content '1 month'
          page.should have_content '12/05/2011'
          page.should have_content 'Inspectable'
          page.should have_content '07/11/2012'
          page.should have_content 'Littleton'
        end
      end

      it 'should show Expiring Equipment report' do
        expiring_equipment = create_equipment(
          customer: @customer,
          name: 'Banana',
          serial_number: 'BANA',
          inspection_interval: Interval::ONE_MONTH.text,
          last_inspection_date: Date.today,
          expiration_date: Date.tomorrow,
          location_id: @denver_location.id
        )

        visit '/'
        page.should have_content 'Equipment Expiring Soon'
        click_link 'Equipment Expiring Soon'

        page.should have_content 'Expiring Equipment List'
        page.should have_content 'Total: 1'
        page.should have_link 'Home'
        page.should have_link 'Create Equipment'

        assert_report_headers_are_correct

        within 'tbody tr', text: 'Banana' do
          page.should have_link 'Banana'
          page.should have_content 'BANA'
          page.should have_content 'Warning'
          page.should have_content '1 month'
          page.should have_content 'Inspectable'
          page.should have_content 'Denver'
        end
      end

      it 'should show Non-Inspectable Equipment report' do
        non_inspectable_equipment = create_equipment(
          customer: @customer,
          name: 'MDC',
          serial_number: 'mdc1',
          inspection_interval: Interval::NOT_REQUIRED.text,
          location_id: @denver_location.id
        )

        visit '/'
        page.should have_content 'Non-Inspectable Equipment'
        click_link 'Non-Inspectable Equipment'

        page.should have_content 'Non-Inspectable Equipment List'
        page.should have_content 'Total: 1'
        page.should have_link 'Home'
        page.should have_link 'Create Equipment'

        assert_report_headers_are_correct

        within 'tbody tr', text: 'MDC' do
          page.should have_link 'MDC'
          page.should have_content 'mdc1'
          page.should have_content 'Not Required'
          page.should have_content 'Inspectable'
          page.should have_content 'Denver'
        end
      end
    end

    context 'when an admin user' do
      before do
        login_as_admin
      end

      it 'should show all equipment for all customers' do
        create_equipment(name: 'Box 123', customer: @customer)
        create_equipment(name: 'Meter 456', customer: @customer)
        create_equipment(name: 'Gauge 987', customer: create_customer)

        click_link 'All Equipment'

        page.should have_content 'Box 123'
        page.should have_content 'Meter 456'
        page.should have_content 'Gauge 987'
      end
    end

    context 'sorting' do
      before do
        login_as_equipment_user
      end

      it 'should sort by name' do
        create_equipment(name: 'zeta', customer: @customer)
        create_equipment(name: 'beta', customer: @customer)
        create_equipment(name: 'alpha', customer: @customer)

        visit '/'
        click_link 'All Equipment'

        # Ascending search
        click_link 'Name'
        column_data_should_be_in_order(['alpha', 'beta', 'zeta'])

        # Descending search
        click_link 'Name'
        column_data_should_be_in_order(['zeta', 'beta', 'alpha'])
      end

      it 'should sort by serial number' do
        create_equipment(serial_number: '222', customer: @customer)
        create_equipment(serial_number: '333', customer: @customer)
        create_equipment(serial_number: '111', customer: @customer)

        visit '/'
        click_link 'All Equipment'

        # Ascending search
        click_link 'Serial Number'
        column_data_should_be_in_order(['111', '222', '333'])

        # Descending search
        click_link 'Serial Number'
        column_data_should_be_in_order(['333', '222', '111'])
      end

      it 'should sort by status' do
        create_expiring_equipment(customer: @customer)
        create_expired_equipment(customer: @customer)
        create_valid_equipment(customer: @customer)

        visit '/'
        click_link 'All Equipment'

        # Ascending search
        click_link 'Status'
        column_data_should_be_in_order([Status::VALID.text, Status::EXPIRING.text, Status::EXPIRED.text])

        # Descending search
        click_link 'Status'
        column_data_should_be_in_order([Status::EXPIRED.text, Status::EXPIRING.text, Status::VALID.text])
      end

      it 'should sort by inspection interval' do
        create_equipment(inspection_interval: Interval::SIX_MONTHS.text, customer: @customer)
        create_equipment(inspection_interval: Interval::TWO_YEARS.text, customer: @customer)
        create_equipment(inspection_interval: Interval::ONE_YEAR.text, customer: @customer)
        create_equipment(inspection_interval: Interval::FIVE_YEARS.text, customer: @customer)
        create_equipment(inspection_interval: Interval::NOT_REQUIRED.text, customer: @customer)
        create_equipment(inspection_interval: Interval::THREE_YEARS.text, customer: @customer)
        create_equipment(inspection_interval: Interval::ONE_MONTH.text, customer: @customer)
        create_equipment(inspection_interval: Interval::THREE_MONTHS.text, customer: @customer)

        visit '/'
        click_link 'All Equipment'

        # Ascending search
        click_link 'Inspection Interval'
        column_data_should_be_in_order(
          [
            Interval::ONE_MONTH.text,
            Interval::THREE_MONTHS.text,
            Interval::SIX_MONTHS.text,
            Interval::ONE_YEAR.text,
            Interval::TWO_YEARS.text,
            Interval::THREE_YEARS.text,
            Interval::FIVE_YEARS.text,
            Interval::NOT_REQUIRED.text
          ]
        )

        # Descending search
        click_link 'Inspection Interval'
        column_data_should_be_in_order(
          [
            Interval::NOT_REQUIRED.text,
            Interval::FIVE_YEARS.text,
            Interval::THREE_YEARS.text,
            Interval::TWO_YEARS.text,
            Interval::ONE_YEAR.text,
            Interval::SIX_MONTHS.text,
            Interval::THREE_MONTHS.text,
            Interval::ONE_MONTH.text
          ]
        )
      end

      it 'should sort by last inspection date' do
        middle_date = Date.new(2013, 6, 15)
        latest_date = Date.new(2013, 12, 31)
        earliest_date = Date.new(2013, 1, 1)

        create_equipment(last_inspection_date: middle_date, customer: @customer)
        create_equipment(last_inspection_date: latest_date, customer: @customer)
        create_equipment(last_inspection_date: earliest_date, customer: @customer)

        visit '/'
        click_link 'All Equipment'

        # Ascending search
        click_link 'Last Inspection Date'
        column_data_should_be_in_order([DateHelpers.format(earliest_date), DateHelpers.format(middle_date), DateHelpers.format(latest_date)])

        # Descending search
        click_link 'Last Inspection Date'
        column_data_should_be_in_order([DateHelpers.format(latest_date), DateHelpers.format(middle_date), DateHelpers.format(earliest_date)])
      end

      it 'should sort by inspection type' do
        inspectable1 = create_equipment(inspection_interval: Interval::ONE_YEAR.text, customer: @customer)
        not_inspectable = create_equipment(inspection_interval: Interval::NOT_REQUIRED.text, customer: @customer)
        inspectable2 = create_equipment(inspection_interval: Interval::FIVE_YEARS.text, customer: @customer)

        visit '/'
        click_link 'All Equipment'

        # Ascending search
        click_link 'Inspection Type'
        column_data_should_be_in_order(["Inspectable", "Inspectable", "Non-Inspectable"])

        # Descending search
        click_link 'Inspection Type'
        column_data_should_be_in_order(["Non-Inspectable", "Inspectable", "Inspectable"])
      end

      it 'should sort by expiration date' do
        middle_date = Date.new(2013, 6, 15)
        latest_date = Date.new(2013, 12, 31)
        earliest_date = Date.new(2013, 1, 1)

        create_equipment(expiration_date: middle_date, customer: @customer)
        create_equipment(expiration_date: latest_date, customer: @customer)
        create_equipment(expiration_date: earliest_date, customer: @customer)
        create_equipment(expiration_date: nil, customer: @customer)

        visit '/'
        click_link 'All Equipment'

        # Ascending search
        click_link 'Expiration Date'
        column_data_should_be_in_order([DateHelpers.format(earliest_date), DateHelpers.format(middle_date), DateHelpers.format(latest_date), ''])

        # Descending search
        click_link 'Expiration Date'
        column_data_should_be_in_order(['', DateHelpers.format(latest_date), DateHelpers.format(middle_date), DateHelpers.format(earliest_date)])
      end

      it 'should sort by assignee' do
        middle_employee = create_employee(first_name: 'Bob', last_name: 'Baker')
        first_employee = create_employee(first_name: 'Albert', last_name: 'Alfonso')
        last_employee = create_employee(first_name: 'Zoe', last_name: 'Zephyr')

        first_location = create_location(name: 'Alcatraz')
        last_location = create_location(name: 'Zurich')
        middle_location = create_location(name: 'Burbank')

        create_equipment(employee: middle_employee, customer: @customer)
        create_equipment(location: last_location, customer: @customer)
        create_equipment(location: first_location, customer: @customer)
        create_equipment(employee: last_employee, customer: @customer)
        create_equipment(employee: first_employee, customer: @customer)
        create_equipment(location: middle_location, customer: @customer)

        visit '/'
        click_link 'All Equipment'

        # Ascending search
        click_link 'Assignee'
        column_data_should_be_in_order(['Alcatraz', 'Alfonso, Albert', 'Baker, Bob', 'Burbank', 'Zephyr, Zoe', 'Zurich'])

        # Descending search
        click_link 'Assignee'
        column_data_should_be_in_order(['Zurich', 'Zephyr, Zoe', 'Burbank', 'Baker, Bob', 'Alfonso, Albert', 'Alcatraz'])
      end
    end

    context 'pagination' do
      before do
        login_as_equipment_user
      end

      it 'should paginate All Equipment report' do
        55.times do
          create_equipment(customer: @customer)
        end

        visit '/'
        click_link 'All Equipment'

        find 'table.sortable'

        page.all('table tr').count.should == 25 + 1
        within 'div.pagination' do
          page.should_not have_link 'Previous'
          page.should_not have_link '1'
          page.should have_link '2'
          page.should have_link '3'
          page.should have_link 'Next'
        end

        click_link 'Next'

        page.all('table tr').count.should == 25 + 1
        within 'div.pagination' do
          page.should have_link 'Previous'
          page.should have_link '1'
          page.should_not have_link '2'
          page.should have_link '3'
          page.should have_link 'Next'
        end

        click_link 'Next'

        page.all('table tr').count.should == 5 + 1
        within 'div.pagination' do
          page.should have_link 'Previous'
          page.should have_link '1'
          page.should have_link '2'
          page.should_not have_link '3'
          page.should_not have_link 'Next'
        end

        click_link 'Previous'
        click_link 'Previous'

        within 'div.pagination' do
          page.should_not have_link 'Previous'
          page.should_not have_link '1'
          page.should have_link '2'
          page.should have_link '3'
          page.should have_link 'Next'
        end
      end
    end
  end

  describe 'Search' do
    context 'when an equipment user' do
      before do
        login_as_equipment_user
      end

      it 'should show Search Equipment page' do
        create_equipment(
          customer: @customer,
          name: 'Unique Name'
        )

        create_equipment(
          customer: @customer,
          name: 'Box'
        )

        visit '/'

        within '[data-equipment-search-form]' do
          click_on 'Search'
        end

        page.should have_content 'Search Equipment'
        page.should have_link 'Home'
        page.should have_link 'Create Equipment'

        fill_in 'Name contains:', with: 'Unique'

        click_on 'Search'

        page.should have_content 'Search Equipment'

        assert_report_headers_are_correct

        find 'table.sortable'

        page.should have_link 'Unique Name'
        page.should_not have_link 'Box'
      end

      it 'should show Search Equipment box' do
        create_equipment(
          customer: @customer,
          name: 'Unique Name'
        )

        create_equipment(
          customer: @customer,
          name: 'Box'
        )

        visit '/'

        within '[data-equipment-search-form]' do
          fill_in 'name', with: 'Unique'
          click_on 'Search'
        end

        page.should have_content 'Search Equipment'

        assert_report_headers_are_correct

        find 'table.sortable'

        page.should have_link 'Unique Name'
        page.should_not have_link 'Box'
      end

      it 'should search and sort simultaneously' do
        create_equipment(
          customer: @customer,
          name: 'Unique Name'
        )

        create_equipment(
          customer: @customer,
          name: 'Box'
        )

        visit '/'
        within '[data-equipment-search-form]' do
          click_on 'Search'
        end

        page.should have_content 'Search Equipment'
        page.should have_link 'Home'
        page.should have_link 'Create Equipment'

        fill_in 'Name contains:', with: 'Unique'

        click_on 'Search'

        page.should have_content 'Search Equipment'

        assert_report_headers_are_correct

        find 'table.sortable'

        page.should have_link 'Unique Name'
        page.should_not have_link 'Box'

        click_on 'Name'

        page.should have_link 'Unique Name'
        page.should_not have_link 'Box'
      end
    end
  end

  def assert_report_headers_are_correct
    within 'table thead tr' do
      page.should have_link 'Name'
      page.should have_link 'Serial Number'
      page.should have_link 'Status'
      page.should have_link 'Inspection Interval'
      page.should have_link 'Last Inspection Date'
      page.should have_link 'Type'
      page.should have_link 'Expiration Date'
      page.should have_link 'Assignee'
    end
  end
end