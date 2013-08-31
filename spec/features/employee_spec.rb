require 'spec_helper'

describe 'Employee', js: true do
  describe 'Create Employee' do
    before do
      login_as_certification_user
      create_location(name: 'Golden', customer_id: @customer.id)
    end

    it 'should create new Employee' do
      visit '/'
      click_link 'Create Employee'

      page.should have_content 'Create Employee'
      page.should have_link 'Home'

      page.should have_content 'First Name'
      page.should have_content 'Last Name'
      page.should have_content 'Employee Number'
      page.should have_content 'Location'

      fill_in 'First Name', with: 'Joe'
      fill_in 'Last Name', with: 'Schmoe'
      fill_in 'Employee Number', with: 'EMP3000'
      select 'Golden', from: 'Location'

      click_on 'Create'

      page.should have_content 'Show Employee'
      page.should have_content 'Employee was successfully created.'

      page.should have_content 'First Name Joe'
      page.should have_content 'Last Name Schmoe'
      page.should have_content 'Employee Number EMP3000'
      page.should have_content 'Location Golden'
    end
  end

  describe 'All Employees' do
    context 'when a certification user' do
      before do
        login_as_certification_user
        @denver_location = create_location(name: 'Denver', customer_id: @customer.id)
        @littleton_location = create_location(name: 'Littleton', customer_id: @customer.id)
      end

      it 'should show All Employee list' do
        create_employee(
          employee_number: 'JB3',
          first_name: 'Joe',
          last_name: 'Brown',
          location_id: @denver_location.id,
          customer_id: @customer.id
        )

        create_employee(
          employee_number: 'SG99',
          first_name: 'Sue',
          last_name: 'Green',
          location_id: @littleton_location.id,
          customer_id: @customer.id
        )

        create_employee(
          employee_number: 'KB123',
          first_name: 'Kim',
          last_name: 'Barnes',
          customer: create_customer
        )

        visit '/'
        page.should have_content 'All Employees'
        click_link 'All Employees'

        page.should have_content 'All Employees'
        page.should have_content 'Total: 2'
        page.should have_link 'Home'
        page.should have_link 'Create Employee'

        assert_report_headers_are_correct

        within 'table tbody tr:nth-of-type(1)' do
          page.should have_link 'JB3'
          page.should have_link 'Joe'
          page.should have_link 'Brown'
          page.should have_content 'Denver'
        end

        within 'table tbody tr:nth-of-type(2)' do
          page.should have_link 'SG99'
          page.should have_link 'Sue'
          page.should have_link 'Green'
          page.should have_content 'Littleton'
        end
      end
    end

    context 'when an admin user' do
      before do
        login_as_admin
      end

      it 'should show all employees for all customers' do
        create_employee(first_name: 'Tom', customer: @customer)
        create_employee(first_name: 'Dick', customer: @customer)
        create_employee(first_name: 'Harry', customer: create_customer)

        click_link 'All Employees'

        page.should have_content 'Tom'
        page.should have_content 'Dick'
        page.should have_content 'Harry'
      end
    end

    context 'sorting' do
      before do
        login_as_certification_user
      end

      it 'should sort by first name' do
        create_employee(first_name: 'zeta', customer: @customer)
        create_employee(first_name: 'beta', customer: @customer)
        create_employee(first_name: 'alpha', customer: @customer)

        visit '/'
        click_link 'All Employees'

        # Ascending search
        click_link 'First Name'
        column_data_should_be_in_order(['alpha', 'beta', 'zeta'])

        # Descending search
        click_link 'First Name'
        column_data_should_be_in_order(['zeta', 'beta', 'alpha'])
      end

      it 'should sort by last name' do
        create_employee(last_name: 'zeta', customer: @customer)
        create_employee(last_name: 'beta', customer: @customer)
        create_employee(last_name: 'alpha', customer: @customer)

        visit '/'
        click_link 'All Employees'

        # Ascending search
        click_link 'Last Name'
        column_data_should_be_in_order(['alpha', 'beta', 'zeta'])

        # Descending search
        click_link 'Last Name'
        column_data_should_be_in_order(['zeta', 'beta', 'alpha'])
      end

      it 'should sort by employee number' do
        create_employee(employee_number: '222', customer: @customer)
        create_employee(employee_number: '333', customer: @customer)
        create_employee(employee_number: '111', customer: @customer)

        visit '/'
        click_link 'All Employees'

        # Ascending search
        click_link 'Employee Number'
        column_data_should_be_in_order(['111', '222', '333'])

        # Descending search
        click_link 'Employee Number'
        column_data_should_be_in_order(['333', '222', '111'])
      end

      it 'should sort by location' do
        first_location = create_location(name: 'Alcatraz')
        last_location = create_location(name: 'Zurich')
        middle_location = create_location(name: 'Burbank')

        create_employee(location: first_location, customer: @customer)
        create_employee(location: last_location, customer: @customer)
        create_employee(location: middle_location, customer: @customer)

        visit '/'
        click_link 'All Employees'

        # Ascending search
        click_link 'Location'
        column_data_should_be_in_order(['Alcatraz', 'Burbank', 'Zurich'])

        # Descending search
        click_link 'Location'
        column_data_should_be_in_order(['Zurich', 'Burbank', 'Alcatraz'])
      end
    end

    context 'pagination' do
      before do
        login_as_certification_user
      end

      it 'should paginate All Employees report' do
        55.times do
          create_employee(customer: @customer)
        end

        visit '/'
        click_link 'All Employees'

        find 'table.sortable'

        page.all('table tr').count.should == 25 + 1
        page.should_not have_link 'Previous'
        page.should_not have_link '1'
        page.should have_link '2'
        page.should have_link '3'
        page.should have_link 'Next'

        click_link 'Next'

        page.all('table tr').count.should == 25 + 1
        page.should have_link 'Previous'
        page.should have_link '1'
        page.should_not have_link '2'
        page.should have_link '3'
        page.should have_link 'Next'

        click_link 'Next'

        page.all('table tr').count.should == 5 + 1
        page.should have_link 'Previous'
        page.should have_link '1'
        page.should have_link '2'
        page.should_not have_link '3'
        page.should_not have_link 'Next'

        click_link 'Previous'
        click_link 'Previous'

        page.should_not have_link 'Previous'
        page.should_not have_link '1'
        page.should have_link '2'
        page.should have_link '3'
        page.should have_link 'Next'
      end
    end
  end

  describe 'Show Employee' do
    before do
      login_as_certification_user
      @denver_location = create_location(name: 'Denver', customer_id: @customer.id)
    end

    it 'should render employee show page' do
      valid_employee = create_employee(
        first_name: 'Sandee',
        last_name: 'Walker',
        employee_number: 'PUP789',
        location_id: @denver_location.id,
        customer: @customer
      )

      visit '/'
      click_link 'All Employee'
      click_link 'Sandee'

      page.should have_content 'Show Employee'
      page.should have_link 'Home'
      page.should have_link 'All Employees'
      page.should have_link 'Create Employee'

      page.should have_content 'Employee Number'
      page.should have_content 'First Name'
      page.should have_content 'Last Name'
      page.should have_content 'Location'

      page.should have_content 'PUP789'
      page.should have_content 'Sandee'
      page.should have_content 'Walker'
      page.should have_content 'Denver'

      page.should have_link 'Edit'
      page.should have_link 'Delete'
    end
  end

  describe 'Update Employee' do
    before do
      login_as_certification_user
      @denver_location = create_location(name: 'Denver', customer_id: @customer.id)
      @littleton_location = create_location(name: 'Littleton', customer_id: @customer.id)
    end

    it 'should update existing employee' do
      valid_employee = create_employee(
        first_name: 'Sandee',
        last_name: 'Walker',
        employee_number: 'PUP789',
        location_id: @denver_location.id,
        customer: @customer
      )

      visit '/'
      click_link 'All Employee'
      click_link 'Sandee'

      page.should have_content 'Show Employee'
      click_on 'Edit'

      page.should have_content 'Edit Employee'
      page.should have_link 'Home'
      page.should have_link 'All Employees'
      page.should have_link 'Create Employee'

      page.should have_content 'Employee Number'
      page.should have_content 'First Name'
      page.should have_content 'Last Name'
      page.should have_content 'Location'

      page.should have_link 'Delete'

      fill_in 'First Name', with: 'Susie'
      fill_in 'Last Name', with: 'Sampson'
      fill_in 'Employee Number', with: '765-CKD'

      select 'Littleton', from: 'Location'

      click_on 'Update'

      page.should have_content 'Show Employee'
      page.should have_content 'Employee was successfully updated.'

      page.should have_content 'Susie'
      page.should have_content 'Sampson'
      page.should have_content '765-CKD'
      page.should have_content 'Littleton'
    end
  end

  describe 'Delete Employee' do
    before do
      login_as_certification_user
      @denver_location = create_location(name: 'Denver', customer_id: @customer.id)
    end

    it 'should delete existing employee' do
      valid_employee = create_employee(
        first_name: 'Sandee',
        last_name: 'Walker',
        employee_number: 'PUP789',
        location_id: @denver_location.id,
        customer: @customer
      )

      visit '/'
      click_link 'All Employees'
      click_link 'Sandee'

      page.should have_content 'Show Employee'
      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete?')
      alert.dismiss

      page.should have_content 'Show Employee'

      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete?')
      alert.accept

      page.should have_content 'All Employees'
      page.should have_content 'Employee was successfully deleted.'
    end

    it 'should not delete employee with equipment assigned' do
      valid_employee = create_employee(
        first_name: 'Sandee',
        last_name: 'Walker',
        employee_number: 'PUP789',
        location_id: @denver_location.id,
        customer: @customer
      )

      create_equipment(employee: valid_employee)

      visit '/'
      click_link 'All Employees'
      click_link 'Sandee'

      page.should have_content 'Show Employee'
      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete?')
      alert.dismiss

      page.should have_content 'Show Employee'

      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete?')
      alert.accept

      page.should have_content 'Show Employee'
      page.should have_content 'Employee has equipment assigned, you must remove them before deleting the employee. Or Deactivate the employee instead.'
    end
  end

  describe 'Deactivate Employee' do
    before do
      login_as_equipment_and_certification_user
      @denver_location = create_location(name: 'Denver', customer_id: @customer.id)
    end

    it 'should deactivate employee and unassign equipment' do
      valid_employee = create_employee(
        first_name: 'Sandee',
        last_name: 'Walker',
        employee_number: 'PUP789',
        location_id: @denver_location.id,
        customer: @customer
      )

      valid_equipment = create_equipment(
        employee: valid_employee,
        customer: @customer,
        name: 'Meter',
        serial_number: 'ABC123',
        inspection_interval: 'Annually',
        last_inspection_date: Date.new(2013, 1, 1),
        expiration_date: Date.new(2024, 2, 3),
        notes: 'my notes'
      )

      visit '/'
      click_link 'All Employees'
      click_link 'Sandee'

      page.should have_content 'Show Employee'
      click_on 'Deactivate'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Deactivate Employee will unassign all equipment and remove employee.  Are you sure?')
      alert.dismiss

      click_on 'Deactivate'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Deactivate Employee will unassign all equipment and remove employee.  Are you sure?')
      alert.accept

      page.should have_content 'Confirm Deactivation'

      page.should have_link 'Home'
      page.should have_content 'Click Deactivate button at bottom to deactivate employee'
      page.should have_content 'The following equipment is assigned to this employee and will be unassigned if you continue:'
      page.should have_content 'Name'
      page.should have_content 'Serial Number'
      page.should have_content 'Status'
      page.should have_content 'Inspection Interval'
      page.should have_content 'Last Inspection Date'
      page.should have_content 'Type'
      page.should have_content 'Expiration Date'
      page.should have_content 'Assignee'

      within 'table tbody tr:nth-of-type(1)' do
        page.should have_content 'Meter'
        page.should have_content 'ABC123'
        page.should have_content 'Valid'
        page.should have_content 'Annually'
        page.should have_content '01/01/2013'
        page.should have_content '02/03/2024'
        page.should have_content 'Walker, Sandee'
      end

      page.should have_content 'Cancel'
      page.should have_content 'Deactivate'

      click_on 'Deactivate'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Deactivate Employee will unassign all equipment and remove employee.  Are you sure?')
      alert.dismiss

      click_on 'Deactivate'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Deactivate Employee will unassign all equipment and remove employee.  Are you sure?')
      alert.accept

      page.should have_content 'All Employees'
      page.should have_content 'Employee Walker, Sandee deactivated'

      page.all('table tr').count.should == 1
      page.should have_content 'Total: 0'

      visit '/'
      click_link 'All Equipment'
      click_link 'Meter'

      page.should have_content 'Show Equipment'
      page.should have_content 'Unassigned'
      page.should_not have_content 'Walker, Sandee'
    end

    it 'should cancel deactivation of employee' do
      valid_employee = create_employee(
        first_name: 'Sandee',
        last_name: 'Walker',
        employee_number: 'PUP789',
        location_id: @denver_location.id,
        customer: @customer
      )

      visit '/'
      click_link 'All Employees'
      click_link 'Sandee'

      page.should have_content 'Show Employee'
      click_on 'Deactivate'

      alert = page.driver.browser.switch_to.alert
      alert.accept

      page.should have_content 'Confirm Deactivation'
      page.should have_content 'No equipment assigned to this employee.'

      click_on 'Cancel'

      page.should have_content 'Show Employee'
    end

  end

  def assert_report_headers_are_correct
    within 'table thead tr' do
      page.should have_link 'Employee Number'
      page.should have_link 'First Name'
      page.should have_link 'Last Name'
      page.should have_link 'Location'
    end
  end
end