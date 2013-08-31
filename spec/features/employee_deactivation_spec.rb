require 'spec_helper'

describe 'Employee Deactivation', js: true do
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

  describe 'Deactivated Employee List' do
    context 'when a certification user' do
      before do
        login_as_certification_user
        @denver_location = create_location(name: 'Denver', customer_id: @customer.id)
        @littleton_location = create_location(name: 'Littleton', customer_id: @customer.id)
      end

      it 'should show Deactivated Employees list' do
        create_employee(
          active: false,
          deactivation_date: Date.new(2000, 1, 1),
          employee_number: 'JB3',
          first_name: 'Joe',
          last_name: 'Brown',
          location_id: @denver_location.id,
          customer_id: @customer.id
        )

        create_employee(
          active: false,
          deactivation_date: Date.new(2001, 12, 31),
          employee_number: 'SG99',
          first_name: 'Sue',
          last_name: 'Green',
          location_id: @littleton_location.id,
          customer_id: @customer.id
        )

        create_employee(
          deactivation_date: Date.new(2013, 4, 4),
          active: false,
          employee_number: 'KB123',
          first_name: 'Kim',
          last_name: 'Barnes',
          customer: create_customer
        )

        visit '/'
        page.should have_content 'Deactivated Employees'
        click_link 'Deactivated Employees'

        page.should have_content 'Deactivated Employee List'
        page.should have_content 'Total: 2'
        page.should have_link 'Home'

        within 'table thead tr' do
          page.should have_content 'Employee Number'
          page.should have_content 'First Name'
          page.should have_content 'Last Name'
          page.should have_content 'Location'
          page.should have_content 'Deactivation Date'
        end

        within 'table tbody tr:nth-of-type(1)' do
          page.should have_content 'JB3'
          page.should have_content 'Joe'
          page.should have_content 'Brown'
          page.should have_content 'Denver'
          page.should have_content '01/01/2000'
        end

        within 'table tbody tr:nth-of-type(2)' do
          page.should have_content 'SG99'
          page.should have_content 'Sue'
          page.should have_content 'Green'
          page.should have_content 'Littleton'
          page.should have_content '12/31/2001'
        end
      end
    end

    context 'when an admin user' do
      before do
        login_as_admin
      end

      it 'should show all deactivated employees for all customers' do
        create_employee(active: false, first_name: 'Tom', customer: @customer)
        create_employee(active: false, first_name: 'Dick', customer: @customer)
        create_employee(active: false, first_name: 'Harry', customer: create_customer)

        click_link 'Deactivated Employees'

        page.should have_content 'Tom'
        page.should have_content 'Dick'
        page.should have_content 'Harry'
      end
    end

    context 'pagination' do
      before do
        login_as_certification_user
      end

      it 'should paginate Deactivated Employees report' do
        55.times do
          create_employee(active: false, customer: @customer)
        end

        visit '/'
        click_link 'Deactivated Employees'

        find 'table'

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
end