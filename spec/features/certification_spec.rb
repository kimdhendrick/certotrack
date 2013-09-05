require 'spec_helper'

describe 'Certifications', js: true do

  describe 'Certify Employee from Show Employee page' do
    before do
      login_as_certification_user
      @certification_type = create_certification_type(
        name: 'CPR',
        interval: Interval::SIX_MONTHS.text,
        customer: @customer
      )

      create_certification_type(
        name: 'Inspections',
        interval: Interval::SIX_MONTHS.text,
        customer: @customer
      )

      @employee = create_employee(
        employee_number: 'JB3',
        first_name: 'Joe',
        last_name: 'Brown',
        customer_id: @customer.id
      )
    end

    it 'should certify employee' do
      visit employee_path @employee.id

      page.should have_link 'New Employee Certification'
      click_on 'New Employee Certification'

      page.should have_content 'Create Certification'

      page.should have_link 'Home'
      #TODO
      #page.should have_link 'All Certifications'
      page.should have_link 'Create Certification Type'
      page.should have_link 'Create Employee'

      page.should have_content 'Employee'
      page.should have_link 'Joe Brown'
      page.should have_content 'Certification Type'
      page.should have_content 'Create Certification Type'
      page.should have_content 'Trainer'
      page.should have_content 'Last Certification Date'
      page.should have_content 'Comments'

      page.should have_button 'Create'
      page.should have_button 'Save and Create Another'

      select 'CPR', from: 'Certification Type'
      fill_in 'Trainer', with: 'Instructor Bob'
      fill_in 'Last Certification Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Employee'
      page.should have_content 'Certification: CPR created for Brown, Joe.'

      #TODO
      #page.should have_content 'Joe'
      #page.should have_content 'Brown'
      #page.should have_content '01/01/2000'
    end

    it 'should alert on future dates' do
      visit employee_path @employee.id

      page.should have_link 'New Employee Certification'
      click_on 'New Employee Certification'

      page.should have_content 'Create Certification'

      page.should have_content 'Employee'
      page.should have_link 'Joe Brown'
      page.should have_content 'Certification Type'
      page.should have_content 'Create Certification Type'
      page.should have_content 'Trainer'
      page.should have_content 'Last Certification Date'
      page.should have_content 'Comments'

      page.should have_button 'Create'
      page.should have_button 'Save and Create Another'

      select 'Inspections', from: 'Certification Type'
      fill_in 'Last Certification Date', with: '01/01/2055'

      click_on 'Create'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to enter a future date?')
      alert.dismiss

      fill_in 'Last Certification Date', with: '01/01/2055'

      click_on 'Save and Create Another'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to enter a future date?')
      alert.accept

      page.should have_content 'Create Certification'
      page.should have_content 'Certification: Inspections created for Brown, Joe.'
    end

    it 'should give error if already certified' do
      create_certification(employee: @employee, certification_type: @certification_type)

      visit employee_path @employee.id

      page.should have_link 'New Employee Certification'
      click_on 'New Employee Certification'

      page.should have_content 'Create Certification'

      page.should have_content 'Employee'
      page.should have_link 'Joe Brown'
      page.should have_content 'Certification Type'
      page.should have_content 'Create Certification Type'
      page.should have_content 'Trainer'
      page.should have_content 'Last Certification Date'
      page.should have_content 'Comments'

      select 'CPR', from: 'Certification Type'
      fill_in 'Trainer', with: 'Instructor Bob'
      fill_in 'Last Certification Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Duplicate certification'

      click_on 'Create'

      page.should have_content 'Create Certification'
      page.should have_content 'This Employee is already Certified for this Certification Type. Please update existing Certification.'
    end

    it 'should certify employee and be ready to create another' do
      visit employee_path @employee.id

      page.should have_link 'New Employee Certification'
      click_on 'New Employee Certification'

      page.should have_content 'Create Certification'

      page.should have_link 'Home'
      #TODO
      #page.should have_link 'All Certifications'
      page.should have_link 'Create Certification Type'
      page.should have_link 'Create Employee'

      page.should have_content 'Employee'
      page.should have_link 'Joe Brown'
      page.should have_content 'Certification Type'
      page.should have_content 'Create Certification Type'
      page.should have_content 'Trainer'
      page.should have_content 'Last Certification Date'
      page.should have_content 'Comments'

      page.should have_button 'Create'
      page.should have_button 'Save and Create Another'

      select 'CPR', from: 'Certification Type'
      fill_in 'Trainer', with: 'Instructor Bob'
      fill_in 'Last Certification Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Save and Create Another'

      page.should have_content 'Create Certification'
      page.should have_content 'Certification: CPR created for Brown, Joe.'

      page.should have_content 'Employee'
      page.should have_link 'Joe Brown'
      page.should have_content 'Certification Type'
      page.should have_content 'Create Certification Type'
      page.should have_content 'Trainer'
      page.should have_content 'Last Certification Date'
      page.should have_content 'Comments'

      page.should have_button 'Create'
      page.should have_button 'Save and Create Another'
    end
  end
end

