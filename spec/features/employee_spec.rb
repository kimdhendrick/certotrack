require 'spec_helper'

describe 'Employee' do
  describe 'Create Employee', js: true do
    before do
      login_as_certification_user
      create_location(name: 'Golden', customer_id: @customer.id)
    end

    it 'should create new Employee' do
      visit '/'
      click_link 'Create Employee'

      page.should have_content 'Create Employee'
      page.should have_link 'Home'

      #Different from CToG, but more consistent, usable:
      #page.should have_link 'Search Employees'

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

      #TODO show employee
      #page.should have_content 'First Name Joe'
      #page.should have_content 'Last Name Schmoe'
      #page.should have_content 'Employee Number EMP3000'
      #page.should have_content 'Location Golden'
    end
  end
end