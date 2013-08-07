require 'spec_helper'

describe 'Equipment', js: true do

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

        page.should have_content 'All Equipment List'
        page.should have_content 'Total: 2'
        page.should have_link 'Home'
        page.should have_link 'Create Equipment'

        assert_report_headers_are_correct

        within 'table tbody tr:nth-of-type(1)' do
          page.should have_link 'Meter'
          page.should have_content 'ABC123'
          page.should have_content 'Valid'
          page.should have_content 'Annually'
          page.should have_content '01/01/2013'
          page.should have_content 'Inspectable'
          page.should have_content '02/03/2024'
          page.should have_content 'Employee, Special'
        end

        within 'table tbody tr:nth-of-type(2)' do
          page.should have_link 'Box'
          page.should have_content 'BBB999'
          page.should have_content 'Expired'
          page.should have_content 'Annually'
          page.should have_content '01/01/2012'
          page.should have_content 'Inspectable'
          page.should have_content '01/01/2013'
          page.should have_content 'Denver'
        end
      end

      it 'should show Expired Equipment report' do
        expired_equipment = create_equipment(
          customer: @customer,
          name: 'Gauge',
          serial_number: 'XYZ987',
          inspection_interval: InspectionInterval::ONE_MONTH.text,
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
  end

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

      page.should have_content 'Level'
      page.should have_content '765-CKD'
      page.should have_content 'Unassigned'
      page.should have_content 'Expired'
      page.should have_content '5 years'
      page.should have_content '01/01/2000'
      page.should have_content '01/01/2005'
      page.should have_content 'Special Notes'
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

      page.should have_content 'Level'
      page.should have_content '765-CKD'
      page.should have_content 'Employee, Special'
      page.should have_content 'Expired'
      page.should have_content '5 years'
      page.should have_content '01/01/2000'
      page.should have_content '01/01/2005'
      page.should have_content 'Special Notes'
    end
  end

  def assert_report_headers_are_correct
    within 'table thead tr' do
      page.should have_content 'Name'
      page.should have_content 'Serial Number'
      page.should have_content 'Status'
      page.should have_content 'Inspection Interval'
      page.should have_content 'Last Inspection Date'
      page.should have_content 'Type'
      page.should have_content 'Expiration Date'
      page.should have_content 'Assignee'
    end
  end
end