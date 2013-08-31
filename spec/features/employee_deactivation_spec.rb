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
end