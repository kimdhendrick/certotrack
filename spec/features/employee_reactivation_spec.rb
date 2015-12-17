require 'spec_helper'

describe 'Employee Reactivation', slow: true do
  let(:customer) { create(:customer) }

  describe 'Deactivate Employee' do
    let(:denver_location) { create(:location, name: 'Denver', customer_id: customer.id) }

    before do
      login_as_equipment_and_certification_user(customer)
    end

    it 'should reactivate employee', js: true do
      inactive_employee = create(
        :employee,
        first_name: 'Sandee',
        last_name: 'Walker',
        employee_number: 'PUP789',
        location_id: denver_location.id,
        customer: customer,
        active: false,
        deactivation_date: Date.yesterday,
      )

      visit dashboard_path
      click_link 'Deactivated Employees'
      click_link 'Reactivate'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Reactivate Employee will restore the employee. All previous certifications will be reactivated. Previously assigned equipment will not be modified. Are you sure?')
      alert.accept

      page.should have_content 'Show Employee'
      page.should have_content 'Employee Walker, Sandee reactivated'

      page.should have_content 'PUP789'
      page.should have_content 'Sandee'
      page.should have_content 'Walker'

      visit dashboard_path
      click_link 'Deactivated Employees'

      page.should_not have_content 'PUP789'
      page.should_not have_content 'Sandee'
      page.should_not have_content 'Walker'
    end
  end
end