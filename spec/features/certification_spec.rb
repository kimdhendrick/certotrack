require 'spec_helper'

describe 'Certifications', slow: true do

  let(:customer) { create(:customer) }

  describe 'Certify' do
    let!(:cpr_certification_type) do
      create(:certification_type,
             name: 'CPR',
             interval: Interval::SIX_MONTHS.text,
             customer: customer
      )
    end

    let!(:truck_inspection_certification_type) do
      create(:certification_type,
             name: 'Level III Truck Inspection',
             interval: Interval::SIX_MONTHS.text,
             units_required: 30,
             customer: customer
      )
    end

    let!(:employee) do
      create(:employee,
             employee_number: 'JB3',
             first_name: 'Joe',
             last_name: 'Brown',
             customer_id: customer.id
      )
    end

    before do
      login_as_certification_user(customer)
      create(:certification_type,
             name: 'Inspections',
             interval: Interval::SIX_MONTHS.text,
             customer: customer
      )
    end

    it 'should toggle units achieved field', js: true do
      visit employee_path employee.id

      page.should have_link 'New Employee Certification'
      click_on 'New Employee Certification'

      select 'Level III Truck Inspection', from: 'Certification Type'
      page.should have_content 'Units Achieved'

      select 'CPR', from: 'Certification Type'
      page.should_not have_content 'Units Achieved'

      select 'Level III Truck Inspection', from: 'Certification Type'
      page.should have_content 'Units Achieved'
    end

    it 'should alert on future dates', js: true do
      visit employee_path employee.id

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
      page.should have_content "Certification 'Inspections' was successfully created for Brown, Joe."
    end

    it 'should give error if already certified' do
      create(:certification, employee: employee, certification_type: cpr_certification_type, customer: employee.customer)

      visit employee_path employee.id

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
      page.should have_content 'Certification type already assigned to this Employee. Please update existing Certification.'
    end

    it 'should show a certification' do
      create(:certification,
             employee: employee,
             certification_type: cpr_certification_type,
             customer: employee.customer,
             last_certification_date: Date.new(2010, 3, 1),
             expiration_date: Date.new(2010, 9, 1),
             trainer: 'Trainer Tim',
             comments: 'Fully qualified')
      create(:certification,
             employee: employee,
             certification_type: truck_inspection_certification_type,
             customer: employee.customer,
             units_achieved: 10,
             last_certification_date: Date.new(2010, 6, 30),
             expiration_date: Date.new(2010, 12, 30),
             trainer: 'Trainer Tom',
             comments: 'Partially qualified')


      visit employee_path employee.id

      click_on 'CPR'

      page.should have_content 'Show Certification'

      page.should have_link 'Home'
      page.should have_link 'Search Certifications'
      page.should have_link 'Create Certification'
      page.should have_link 'Create Employee'

      page.should have_content 'Certification Type'
      page.should have_content 'Certification Interval'
      page.should have_content 'Employee'
      page.should have_content 'Trainer'
      page.should have_content 'Status'
      page.should have_content 'Last Certification Date'
      page.should have_content 'Expiration Date'
      page.should_not have_content 'Units Achieved'
      page.should have_content 'Comments'

      page.should have_link 'CPR'
      page.should have_content '6 months'
      page.should have_link 'Brown, Joe'
      page.should have_content 'Trainer Tim'
      page.should have_content 'Expired'
      page.should have_content '03/01/2010'
      page.should have_content '09/01/2010'
      page.should have_content 'Fully qualified'

      page.should have_link 'Edit'
      page.should have_link 'Delete'

      visit certification_type_path cpr_certification_type.id

      within '[data-certified] table tbody tr:nth-of-type(1)' do
        click_on 'Edit'
      end

      page.should have_content 'Show Certification'

      page.should have_link 'Home'
      page.should have_link 'Search Certifications'
      page.should have_link 'Create Certification'
      page.should have_link 'Create Employee'

      page.should have_content 'Certification Type'
      page.should have_content 'Certification Interval'
      page.should have_content 'Employee'
      page.should have_content 'Trainer'
      page.should have_content 'Status'
      page.should have_content 'Last Certification Date'
      page.should have_content 'Expiration Date'
      page.should_not have_content 'Units Achieved'
      page.should have_content 'Comments'

      page.should have_content 'CPR'
      page.should have_content '6 months'
      page.should have_link 'Brown, Joe'
      page.should have_content 'Trainer Tim'
      page.should have_content 'Expired'
      page.should have_content '03/01/2010'
      page.should have_content '09/01/2010'
      page.should have_content 'Fully qualified'

      page.should have_link 'Edit'
      page.should have_link 'Delete'

      visit employee_path employee.id

      click_on 'Level III Truck Inspection'
      page.should have_content 'Show Certification'

      page.should have_link 'Home'
      page.should have_link 'Search Certifications'
      page.should have_link 'Create Certification'
      page.should have_link 'Create Employee'

      page.should have_content 'Certification Type'
      page.should have_content 'Certification Interval'
      page.should have_content 'Employee'
      page.should have_content 'Trainer'
      page.should have_content 'Status'
      page.should have_content 'Last Certification Date'
      page.should have_content 'Expiration Date'
      page.should have_content 'Units Achieved'
      page.should have_content 'Comments'

      page.should have_link 'Level III Truck Inspection'
      page.should have_content '6 months'
      page.should have_link 'Brown, Joe'
      page.should have_content 'Trainer Tom'
      page.should have_content 'Recertify'
      page.should have_content '06/30/2010'
      page.should have_content '12/30/2010'
      page.should have_content '10 of 30'
      page.should have_content 'Partially qualified'

      page.should have_link 'Edit'
      page.should have_link 'Delete'

      visit certification_type_path truck_inspection_certification_type.id

      within '[data-certified] table tbody tr:nth-of-type(1)' do
        click_on 'Edit'
      end

      page.should have_content 'Show Certification'

      page.should have_link 'Home'
      page.should have_link 'Search Certifications'
      page.should have_link 'Create Certification'
      page.should have_link 'Create Employee'

      page.should have_content 'Certification Type'
      page.should have_content 'Certification Interval'
      page.should have_content 'Employee'
      page.should have_content 'Trainer'
      page.should have_content 'Status'
      page.should have_content 'Last Certification Date'
      page.should have_content 'Expiration Date'
      page.should have_content 'Units Achieved'
      page.should have_content 'Comments'

      page.should have_content 'Level III Truck Inspection'
      page.should have_content '6 months'
      page.should have_content 'Trainer Tom'
      page.should have_content 'Recertify'
      page.should have_content '06/30/2010'
      page.should have_content '12/30/2010'
      page.should have_content '10 of 30'
      page.should have_content 'Partially qualified'

      page.should have_link 'Edit'
      page.should have_link 'Delete'

    end
  end

  describe 'Certify Employee from Show Employee page' do
    let!(:cpr_certification_type) do
      create(:certification_type,
             name: 'CPR',
             interval: Interval::SIX_MONTHS.text,
             customer: customer
      )
    end

    let!(:employee) do
      create(:employee,
             employee_number: 'JB3',
             first_name: 'Joe',
             last_name: 'Brown',
             customer_id: customer.id
      )
    end

    before do
      login_as_certification_user(customer)
      create(:certification_type,
             name: 'Level III Truck Inspection',
             interval: Interval::SIX_MONTHS.text,
             units_required: 30,
             customer: customer
      )

      create(:certification_type,
             name: 'Inspections',
             interval: Interval::SIX_MONTHS.text,
             customer: customer
      )
    end

    it 'should certify employee' do
      visit employee_path employee.id

      page.should have_link 'New Employee Certification'
      click_on 'New Employee Certification'

      page.should have_content 'Create Certification'

      page.should have_link 'Home'
      page.should have_link 'Search Certifications'
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
      page.should have_content "Certification 'CPR' was successfully created for Brown, Joe."

      page.should have_content 'Joe'
      page.should have_content 'Brown'
      page.should have_content '01/01/2000'
    end

    it 'should certify employee for units based certifications', js: true do
      visit employee_path employee.id
      click_on 'New Employee Certification'

      page.should have_content 'Create Certification'

      page.should have_content 'Employee'
      page.should have_link 'Joe Brown'
      page.should have_content 'Certification Type'
      page.should have_content 'Create Certification Type'
      page.should have_content 'Trainer'
      page.should_not have_content 'Units Achieved'
      page.should have_content 'Last Certification Date'
      page.should have_content 'Comments'

      page.should have_button 'Create'
      page.should have_button 'Save and Create Another'

      select 'Level III Truck Inspection', from: 'Certification Type'
      page.should have_content 'Units Achieved'
      fill_in 'Trainer', with: 'Instructor Bob'
      fill_in 'Units Achieved', with: '15'
      fill_in 'Last Certification Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Employee'
      page.should have_content "Certification 'Level III Truck Inspection' was successfully created for Brown, Joe."
      page.should have_content '15 of 30'
    end

    it 'should certify employee and be ready to create another' do
      visit employee_path employee.id

      page.should have_link 'New Employee Certification'
      click_on 'New Employee Certification'

      page.should have_content 'Create Certification'

      page.should have_link 'Home'
      page.should have_link 'Search Certifications'
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
      page.should have_content "Certification 'CPR' was successfully created for Brown, Joe."

      page.should have_content 'Employee'
      page.should have_link 'Joe Brown'
      page.should have_content 'Certification Type'
      page.should have_content 'Create Certification Type'
      page.should have_content 'Trainer'
      page.should have_content 'Last Certification Date'
      page.should have_content 'Comments'

      page.should have_button 'Create'
      page.should have_button 'Save and Create Another'

      select 'Level III Truck Inspection', from: 'Certification Type'
      fill_in 'Trainer', with: 'Instructor Bob'
      fill_in 'Last Certification Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Employee'
      page.should have_content "Certification 'Level III Truck Inspection' was successfully created for Brown, Joe."
    end
  end

  describe 'Certify Employee from Show Certification page' do
    let!(:cpr_certification_type) do
      create(:certification_type,
             name: 'CPR',
             interval: Interval::SIX_MONTHS.text,
             customer: customer
      )
    end

    let!(:employee) do
      create(:employee,
             employee_number: 'JB3',
             first_name: 'Joe',
             last_name: 'Brown',
             customer_id: customer.id
      )
    end

    let(:certification) do
      create(
        :certification,
        employee: employee,
        certification_type: cpr_certification_type,
        customer: employee.customer)
    end

    before do
      login_as_certification_user(customer)

      create(:certification_type,
             name: 'Inspections',
             interval: Interval::SIX_MONTHS.text,
             customer: customer
      )

      create(:certification_type,
             name: 'Level III Truck Inspection',
             interval: Interval::SIX_MONTHS.text,
             units_required: 30,
             customer: customer
      )

    end

    it 'should certify employee', js: true do
      visit certification_path certification.id

      page.should have_content 'Show Certification'
      click_on 'Create Certification'

      page.should have_content 'Create Certification'

      page.should have_link 'Home'
      page.should have_link 'Search Certifications'
      page.should have_link 'Create Employee'

      page.should have_content 'Employee'
      page.should have_link 'Create Employee'
      page.should have_content 'Certification Type'
      page.should have_link 'Create Certification Type'
      page.should_not have_content 'Units Achieved'
      page.should have_content 'Trainer'
      page.should have_content 'Last Certification Date'
      page.should have_content 'Comments'

      page.should have_button 'Create'
      page.should have_button 'Save and Create Another'

      select 'Brown, Joe', from: 'Employee'
      select 'Inspections', from: 'Certification Type'
      fill_in 'Trainer', with: 'Instructor Bob'
      fill_in 'Last Certification Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Certification Type'
      page.should have_content "Certification 'Inspections' was successfully created for Brown, Joe."

      page.should have_content 'Joe'
      page.should have_content 'Brown'
      page.should have_content '01/01/2000'
    end

    it 'should certify employee for units based certifications', js: true do
      visit certification_path certification.id
      page.should have_content 'Show Certification'

      click_on 'Create Certification'

      page.should have_content 'Create Certification'

      page.should have_content 'Employee'
      page.should have_link 'Create Employee'
      page.should have_content 'Certification Type'
      page.should have_content 'Create Certification Type'
      page.should have_content 'Trainer'
      page.should_not have_content 'Units Achieved'
      page.should have_content 'Last Certification Date'
      page.should have_content 'Comments'

      page.should have_button 'Create'
      page.should have_button 'Save and Create Another'

      select 'Brown, Joe', from: 'Employee'
      select 'Level III Truck Inspection', from: 'Certification Type'
      page.should have_content 'Units Achieved'
      fill_in 'Trainer', with: 'Instructor Bob'
      fill_in 'Units Achieved', with: '15'
      fill_in 'Last Certification Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Certification Type'
      page.should have_content "Certification 'Level III Truck Inspection' was successfully created for Brown, Joe."
      page.should have_content '15 of 30'
    end

    it 'should certify employee and be ready to create another' do
      visit certification_path certification.id

      page.should have_content 'Show Certification'
      click_on 'Create Certification'

      page.should have_content 'Create Certification'

      page.should have_link 'Home'
      page.should have_link 'Search Certifications'
      page.should have_link 'Create Employee'

      page.should have_content 'Employee'
      page.should have_content 'Certification Type'
      page.should have_content 'Create Certification Type'
      page.should have_content 'Trainer'
      page.should have_content 'Last Certification Date'
      page.should have_content 'Comments'

      page.should have_button 'Create'
      page.should have_button 'Save and Create Another'

      select 'Brown, Joe', from: 'Employee'
      select 'Inspections', from: 'Certification Type'
      fill_in 'Trainer', with: 'Instructor Bob'
      fill_in 'Last Certification Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Save and Create Another'

      page.should have_content 'Create Certification'
      page.should have_content "Certification 'Inspections' was successfully created for Brown, Joe."

      page.should have_content 'Employee'
      page.should have_content 'Certification Type'
      page.should have_content 'Create Certification Type'
      page.should have_content 'Trainer'
      page.should have_content 'Last Certification Date'
      page.should have_content 'Comments'

      page.should have_button 'Create'
      page.should have_button 'Save and Create Another'

      select 'Level III Truck Inspection', from: 'Certification Type'
      fill_in 'Trainer', with: 'Instructor Bob'
      fill_in 'Last Certification Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Certification Type'
      page.should have_content "Certification 'Level III Truck Inspection' was successfully created for Brown, Joe."
    end
  end

  describe 'Certify Employee from Show Certification Type page' do
    let!(:cpr_certification_type) do
      create(:certification_type,
             name: 'CPR',
             interval: Interval::SIX_MONTHS.text,
             customer: customer
      )
    end

    let!(:employee) do
      create(:employee,
             employee_number: 'JB3',
             first_name: 'Joe',
             last_name: 'Brown',
             customer_id: customer.id
      )
    end

    before do
      login_as_certification_user(customer)
      create(:certification_type,
             name: 'AAA Truck Inspection',
             interval: Interval::SIX_MONTHS.text,
             units_required: 30,
             customer: customer
      )

      create(:certification_type,
             name: 'Inspections',
             interval: Interval::SIX_MONTHS.text,
             customer: customer
      )
    end

    it 'should certify employee' do
      visit certification_type_path cpr_certification_type.id

      within 'tbody tr', text: 'JB3' do
        click_on 'Certify'
      end

      page.should have_content 'Create Certification'

      page.should have_link 'Home'
      page.should have_link 'Search Certifications'
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

      find_field('Certification Type').value.should eq cpr_certification_type.id.to_s
      fill_in 'Trainer', with: 'Instructor Bob'
      fill_in 'Last Certification Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Certification Type'
      page.should have_content "Certification 'CPR' was successfully created for Brown, Joe."
    end

    it 'should certify employee and be ready to create another' do
      visit certification_type_path cpr_certification_type.id

      within 'tbody tr', text: 'JB3' do
        click_on 'Certify'
      end

      page.should have_content 'Create Certification'

      select 'CPR', from: 'Certification Type'
      fill_in 'Trainer', with: 'Instructor Bob'
      fill_in 'Last Certification Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Save and Create Another'

      page.should have_content 'Create Certification'
      page.should have_content "Certification 'CPR' was successfully created for Brown, Joe."

      page.should have_content 'Employee'
      page.should have_link 'Joe Brown'
      page.should have_content 'Certification Type'
      page.should have_content 'Create Certification Type'
      page.should have_content 'Trainer'
      page.should have_content 'Last Certification Date'
      page.should have_content 'Comments'

      page.should have_button 'Create'
      page.should have_button 'Save and Create Another'

      select 'AAA Truck Inspection', from: 'Certification Type'
      fill_in 'Trainer', with: 'Instructor Bob'
      fill_in 'Last Certification Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Certification Type'
      page.should have_content "Certification 'AAA Truck Inspection' was successfully created for Brown, Joe."
    end
  end

  describe 'Edit Certification from Show Certification page', js: true do
    let!(:cpr_certification_type) do
      create(:certification_type,
             name: 'CPR',
             interval: Interval::SIX_MONTHS.text,
             customer: customer
      )
    end

    let!(:employee) do
      create(:employee,
             employee_number: 'JB3',
             first_name: 'Joe',
             last_name: 'Brown',
             location: create(:location, name: 'Denver'),
             customer_id: customer.id
      )
    end

    let(:certification) do
      create(
        :certification,
        employee: employee,
        certification_type: cpr_certification_type,
        last_certification_date: Date.new(2005, 7, 8),
        trainer: 'Trainer Tim',
        comments: 'Fully qualified',
        customer: employee.customer)
    end

    before do
      login_as_certification_user(customer)

      create(:certification_type,
             name: 'Level III Truck Inspection',
             interval: Interval::SIX_MONTHS.text,
             units_required: 30,
             customer: customer
      )
    end

    it 'should edit certification' do
      visit certification_path certification.id

      page.should have_content 'Show Certification'
      click_on 'Edit'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to edit instead of recertify?')
      alert.dismiss

      page.should have_content 'Show Certification'
      click_on 'Edit'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to edit instead of recertify?')
      alert.accept

      page.should have_content 'Edit Certification'

      page.should have_link 'Home'
      page.should have_link 'Search Certifications'
      page.should have_link 'Create Certification'

      page.should have_content 'Employee'
      page.should have_content 'Certification Type'
      page.should have_content 'Trainer'
      page.should_not have_content 'Units Achieved'
      page.should have_content 'Last Certification Date'
      page.should have_content 'Comments'

      page.should have_field 'Certification Type', with: certification.certification_type.id.to_s
      page.should have_link 'Joe Brown'
      page.should have_field 'Trainer', with: 'Trainer Tim'
      page.should have_field 'Last Certification Date', with: '07/08/2005'
      page.should have_field 'Comments', with: 'Fully qualified'

      page.should have_link 'Delete'

      click_on 'Delete'
      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this certification?')
      alert.dismiss

      select 'Level III Truck Inspection', from: 'Certification Type'
      fill_in 'Trainer', with: 'Trainer Tom'
      fill_in 'Units Achieved', with: '13'
      fill_in 'Last Certification Date', with: '07/09/2005'

      click_on 'Update'

      page.should have_content 'Show Certification Type'
      page.should have_content "Certification 'Level III Truck Inspection' was successfully updated for Brown, Joe."
      page.should have_content 'Level III Truck Inspection'

      within '[data-certified] table tbody tr:nth-of-type(1)' do
        page.should have_link 'Brown, Joe'
        page.should have_content 'JB3'
        page.should have_content 'Denver'
        page.should have_content '13'
        page.should have_content 'Trainer Tom'
        page.should have_content '07/09/2005'
        page.should have_content '01/09/2006'
        page.should have_content 'Recertify'
        page.should have_link 'Edit'
      end

      visit certification_path certification.id

      page.should have_content 'Show Certification'
      click_on 'Edit'

      page.driver.browser.switch_to.alert.accept

      page.should have_content 'Edit Certification'

      page.should have_field 'Units Achieved', with: '13'
    end
  end

  describe 'Delete Certification' do
    let!(:cpr_certification_type) do
      create(:certification_type,
             name: 'CPR',
             interval: Interval::SIX_MONTHS.text,
             customer: customer
      )
    end

    let!(:employee) do
      create(:employee,
             employee_number: 'JB3',
             first_name: 'Joe',
             last_name: 'Brown',
             location: create(:location, name: 'Denver'),
             customer_id: customer.id
      )
    end

    let(:certification) do
      create(
        :certification,
        employee: employee,
        certification_type: cpr_certification_type,
        last_certification_date: Date.new(2005, 7, 8),
        trainer: 'Trainer Tim',
        comments: 'Fully qualified',
        customer: employee.customer)
    end

    before do
      login_as_certification_user(customer)
    end

    it 'should delete existing certification from show page', js: true do
      visit certification_path certification.id

      page.should have_content 'Show Certification'
      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this certification?')
      alert.dismiss

      page.should have_content 'Show Certification'
      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this certification?')
      alert.accept

      page.should have_content 'Show Certification Type'
      page.should have_content "Certification 'CPR' was successfully deleted for Brown, Joe."
    end

    it 'should delete existing certification from edit page', js: true do
      visit certification_path certification.id
      click_on 'Edit'

      page.driver.browser.switch_to.alert.accept

      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this certification?')
      alert.dismiss

      page.should have_content 'Edit Certification'
      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this certification?')
      alert.accept

      page.should have_content 'Show Certification Type'
      page.should have_content "Certification 'CPR' was successfully deleted for Brown, Joe."
    end
  end

  describe 'Certification History' do
    let!(:cpr_certification_type) do
      create(:certification_type,
             name: 'CPR',
             interval: Interval::SIX_MONTHS.text,
             customer: customer
      )
    end

    let!(:truck_certification_type) do
      create(:certification_type,
             name: 'Level III Truck Inspection',
             interval: Interval::SIX_MONTHS.text,
             units_required: 30,
             customer: customer
      )
    end

    let!(:employee) do
      create(:employee,
             employee_number: 'JB3',
             first_name: 'Joe',
             last_name: 'Brown',
             location: create(:location, name: 'Denver'),
             customer_id: customer.id
      )
    end

    let(:cpr_certification) do
      create(
        :certification,
        employee: employee,
        certification_type: cpr_certification_type,
        last_certification_date: Date.new(2005, 7, 8),
        expiration_date: Date.new(2006, 1, 8),
        trainer: 'Trainer Tim',
        customer: employee.customer)
    end

    let(:truck_certification) do
      create(
        :certification,
        employee: employee,
        certification_type: truck_certification_type,
        last_certification_date: Date.new(2007, 12, 10),
        expiration_date: Date.new(2008, 6, 10),
        trainer: 'Trucker Joe',
        customer: employee.customer)
    end

    before do
      login_as_certification_user(customer)
    end

    context 'date based certification' do
      it 'should list historical certifications' do
        visit certification_path(cpr_certification)

        click_on 'Recertify'
        fill_in 'Trainer', with: 'Instructor Joe'
        fill_in 'Last Certification Date', with: '07/08/2006'
        click_button 'Recertify'

        page.should have_link 'Certification History'

        page.should have_link 'Home'
        page.should have_link 'Search Certifications'

        click_on 'Certification History'

        page.should have_content 'Show Certification History'

        page.should have_content 'Employee'
        page.should have_content 'Certification Type'
        page.should have_content 'Certification Interval'

        page.should have_link 'Brown, Joe'
        page.should have_link 'CPR'
        page.should have_content '6 months'

        page.should have_content 'Certification History (CPR)'

        within '[data-historical] table thead tr' do
          page.should have_content 'Last Certification Date'
          page.should have_content 'Expiration Date'
          page.should have_content 'Trainer'
          page.should have_content 'Status'
        end

        within '[data-historical] table tbody tr:nth-of-type(1)' do
          page.should have_content 'Active'
          page.should have_content '07/08/2006'
          page.should have_content '01/08/2007'
          page.should have_content 'Instructor Joe'
          page.should have_content 'Expired'
        end

        within '[data-historical] table tbody tr:nth-of-type(2)' do
          page.should_not have_content 'Active'
          page.should have_content '07/08/2005'
          page.should have_content '01/08/2006'
          page.should have_content 'Trainer Tim'
          page.should_not have_content 'Expired'
        end
      end
    end

    context 'units based certification' do
      it 'should list historical certifications' do
        visit certification_path(truck_certification)

        click_on 'Recertify'
        fill_in 'Trainer', with: 'Instructor Joe'
        fill_in 'Last Certification Date', with: '07/08/2008'
        fill_in 'Units Achieved', with: '7'
        click_button 'Recertify'

        page.should have_link 'Certification History'

        page.should have_link 'Home'
        page.should have_link 'Search Certifications'

        click_on 'Certification History'

        page.should have_content 'Show Certification History'

        page.should have_content 'Employee'
        page.should have_content 'Certification Type'
        page.should have_content 'Certification Interval'

        page.should have_link 'Brown, Joe'
        page.should have_link 'Level III Truck Inspection'
        page.should have_content '6 months'

        page.should have_content 'Certification History (Level III Truck Inspection)'

        within '[data-historical] table thead tr' do
          page.should have_content 'Last Certification Date'
          page.should have_content 'Expiration Date'
          page.should have_content 'Units'
          page.should have_content 'Trainer'
          page.should have_content 'Status'
        end

        within '[data-historical] table tbody tr:nth-of-type(1)' do
          page.should have_content 'Active'
          page.should have_content '07/08/2008'
          page.should have_content '01/08/2009'
          page.should have_content '7 of 30'
          page.should have_content 'Instructor Joe'
          page.should have_content 'Recertify'
        end

        within '[data-historical] table tbody tr:nth-of-type(2)' do
          page.should_not have_content 'Active'
          page.should have_content '12/10/2007'
          page.should have_content '06/10/2008'
          page.should have_content '0 of 30'
          page.should have_content 'Trucker Joe'
          page.should_not have_content 'Expired'
        end
      end
    end
  end
end