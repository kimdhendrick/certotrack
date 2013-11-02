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
      page.should have_content 'Certification: Inspections created for Brown, Joe.'
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
      page.should have_link 'All Employee Certifications'
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
      page.should have_link 'All Employee Certifications'
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
      page.should have_link 'All Employee Certifications'
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
      page.should have_link 'All Employee Certifications'
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
      page.should have_link 'All Employee Certifications'
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
      page.should have_content 'Certification: Level III Truck Inspection created for Brown, Joe.'
      page.should have_content '15 of 30'
    end

    it 'should certify employee and be ready to create another' do
      visit employee_path employee.id

      page.should have_link 'New Employee Certification'
      click_on 'New Employee Certification'

      page.should have_content 'Create Certification'

      page.should have_link 'Home'
      page.should have_link 'All Employee Certifications'
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

      select 'Level III Truck Inspection', from: 'Certification Type'
      fill_in 'Trainer', with: 'Instructor Bob'
      fill_in 'Last Certification Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Employee'
      page.should have_content 'Certification: Level III Truck Inspection created for Brown, Joe.'
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
      page.should have_link 'All Employee Certifications'
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
      page.should have_content 'Certification: Inspections created for Brown, Joe.'

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
      page.should have_content 'Certification: Level III Truck Inspection created for Brown, Joe.'
      page.should have_content '15 of 30'
    end

    it 'should certify employee and be ready to create another' do
      visit certification_path certification.id

      page.should have_content 'Show Certification'
      click_on 'Create Certification'

      page.should have_content 'Create Certification'

      page.should have_link 'Home'
      page.should have_link 'All Employee Certifications'
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
      page.should have_content 'Certification: Inspections created for Brown, Joe.'

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
      page.should have_content 'Certification: Level III Truck Inspection created for Brown, Joe.'
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
      page.should have_link 'All Employee Certifications'
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
      page.should have_content 'Certification: CPR created for Brown, Joe.'
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

      select 'AAA Truck Inspection', from: 'Certification Type'
      fill_in 'Trainer', with: 'Instructor Bob'
      fill_in 'Last Certification Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Certification Type'
      page.should have_content 'Certification: AAA Truck Inspection created for Brown, Joe.'
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
      page.should have_link 'All Employee Certifications'
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
      page.should have_content 'Certification was successfully updated.'
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
      page.should have_content 'Certification for Brown, Joe deleted'
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
      page.should have_content 'Certification for Brown, Joe deleted'
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
        page.should have_link 'All Employee Certifications'

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
        page.should have_link 'All Employee Certifications'

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

  describe 'All Employee Certifications' do
    context 'when a certification user' do
      let!(:cpr_certification_type) do
        create(:certification_type,
               name: 'CPR',
               interval: Interval::ONE_YEAR.text,
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

      let!(:cpr_certification) do
        create(
          :certification,
          employee: employee,
          certification_type: cpr_certification_type,
          last_certification_date: Date.new(2005, 7, 8),
          expiration_date: Date.new(2006, 1, 8),
          trainer: 'Trainer Tim',
          customer: employee.customer)
      end

      let!(:truck_certification) do
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

      it 'should list all employee certifications' do
        visit '/'
        page.should have_content 'All Employee Certifications (2)'
        click_link 'All Employee Certifications (2)'

        page.should have_content 'All Employee Certifications'
        page.should have_content 'Total: 2'

        within 'table thead tr' do
          page.should have_link 'Certification Type'
          page.should have_link 'Interval'
          page.should have_link 'Units'
          page.should have_link 'Status'
          page.should have_link 'Employee'
          page.should have_link 'Trainer'
          page.should have_link 'Last Certification Date'
          page.should have_link 'Expiration Date'
        end

        within 'table tbody tr:nth-of-type(1)' do
          page.should have_link 'CPR'
          page.should have_content 'Annually'
          page.should have_content 'Expired'
          page.should have_content 'Brown, Joe'
          page.should have_content 'Trainer Tim'
          page.should have_content '07/08/2005'
          page.should have_content '01/08/2006'
        end

        within 'table tbody tr:nth-of-type(2)' do
          page.should have_link 'Level III Truck Inspection'
          page.should have_content '6 months'
          page.should have_content '0 of 30'
          page.should have_content 'Recertify'
          page.should have_content 'Brown, Joe'
          page.should have_content 'Trucker Joe'
          page.should have_content '12/10/2007'
          page.should have_content '06/10/2008'
        end
      end
    end

    context 'when an admin user' do
      let(:customer1) { create(:customer) }
      let(:customer2) { create(:customer) }

      let(:certification_type1) do
        create(:certification_type,
               name: 'CPR',
               customer: customer1
        )
      end

      let(:certification_type2) do
        create(:certification_type,
               name: 'Level III Truck Inspection',
               customer: customer2
        )
      end

      let(:employee1) do
        create(:employee,
               customer_id: customer1.id
        )
      end

      let(:employee2) do
        create(:employee,
               customer_id: customer2.id
        )
      end

      let!(:certification1) do
        create(
          :certification,
          employee: employee1,
          certification_type: certification_type1,
          customer: customer1)
      end

      let!(:certification2) do
        create(
          :certification,
          employee: employee2,
          certification_type: certification_type2,
          customer: customer2)
      end

      before do
        login_as_admin
      end

      it 'should show all certifications for all customers' do
        click_link 'All Employee Certifications (2)'

        page.should have_content 'CPR'
        page.should have_content 'Level III Truck Inspection'
      end
    end

    context 'sorting' do
      before do
        login_as_certification_user(customer)
      end

      it 'should sort by certification type name' do
        zeta = create(:certification_type, name: 'zeta', customer: customer)
        beta = create(:certification_type, name: 'beta', customer: customer)
        alpha = create(:certification_type, name: 'alpha', customer: customer)
        create(:certification, certification_type: zeta, customer: customer)
        create(:certification, certification_type: beta, customer: customer)
        create(:certification, certification_type: alpha, customer: customer)

        visit '/'
        click_link 'All Employee Certifications'

        # Ascending sort
        click_link 'Certification Type'
        column_data_should_be_in_order('alpha', 'beta', 'zeta')

        # Descending sort
        click_link 'Certification Type'
        column_data_should_be_in_order('zeta', 'beta', 'alpha')
      end

      it 'should sort by interval' do
        create(:certification, certification_type: create(:certification_type, interval: Interval::SIX_MONTHS.text, customer: customer))
        create(:certification, certification_type: create(:certification_type, interval: Interval::TWO_YEARS.text, customer: customer))
        create(:certification, certification_type: create(:certification_type, interval: Interval::ONE_YEAR.text, customer: customer))
        create(:certification, certification_type: create(:certification_type, interval: Interval::FIVE_YEARS.text, customer: customer))
        create(:certification, certification_type: create(:certification_type, interval: Interval::NOT_REQUIRED.text, customer: customer))
        create(:certification, certification_type: create(:certification_type, interval: Interval::THREE_YEARS.text, customer: customer))
        create(:certification, certification_type: create(:certification_type, interval: Interval::ONE_MONTH.text, customer: customer))
        create(:certification, certification_type: create(:certification_type, interval: Interval::THREE_MONTHS.text, customer: customer))

        visit '/'
        click_link 'All Employee Certifications'

        # Ascending sort
        click_link 'Interval'
        column_data_should_be_in_order(
          Interval::ONE_MONTH.text,
          Interval::THREE_MONTHS.text,
          Interval::SIX_MONTHS.text,
          Interval::ONE_YEAR.text,
          Interval::TWO_YEARS.text,
          Interval::THREE_YEARS.text,
          Interval::FIVE_YEARS.text,
          Interval::NOT_REQUIRED.text
        )

        # Descending sort
        click_link 'Interval'
        column_data_should_be_in_order(
          Interval::NOT_REQUIRED.text,
          Interval::FIVE_YEARS.text,
          Interval::THREE_YEARS.text,
          Interval::TWO_YEARS.text,
          Interval::ONE_YEAR.text,
          Interval::SIX_MONTHS.text,
          Interval::THREE_MONTHS.text,
          Interval::ONE_MONTH.text
        )
      end

      it 'should sort by status' do
        expired = create(:certification, expiration_date: Date.yesterday, customer: customer)
        warning = create(:certification, expiration_date: Date.tomorrow, customer: customer)
        valid = create(:certification, expiration_date: (Date.today)+120, customer: customer)

        visit '/'
        click_link 'All Employee Certifications'

        # Ascending sort
        click_link 'Status'
        column_data_should_be_in_order(valid.status, warning.status, expired.status)

        # Descending sort
        click_link 'Status'
        column_data_should_be_in_order(expired.status, warning.status, valid.status)
      end

      it 'should sort by employee' do
        zeta = create(:certification, employee: create(:employee, last_name: 'zeta', first_name: 'a'), customer: customer)
        beta = create(:certification, employee: create(:employee, last_name: 'beta', first_name: 'a'), customer: customer)
        alpha = create(:certification, employee: create(:employee, last_name: 'alpha', first_name: 'a'), customer: customer)

        visit '/'
        click_link 'All Employee Certifications'

        # Ascending sort
        click_link 'Employee'
        column_data_should_be_in_order(alpha.employee.last_name, beta.employee.last_name, zeta.employee.last_name)

        # Descending sort
        click_link 'Employee'
        column_data_should_be_in_order(zeta.employee.last_name, beta.employee.last_name, alpha.employee.last_name)
      end

      it 'should sort by trainer' do
        zeta = create(:certification, trainer: 'zeta', customer: customer)
        beta = create(:certification, trainer: 'beta', customer: customer)
        alpha = create(:certification, trainer: 'alpha', customer: customer)

        visit '/'
        click_link 'All Employee Certifications'

        # Ascending sort
        click_link 'Trainer'
        column_data_should_be_in_order(alpha.trainer, beta.trainer, zeta.trainer)

        # Descending sort
        click_link 'Trainer'
        column_data_should_be_in_order(zeta.trainer, beta.trainer, alpha.trainer)
      end

      it 'should sort by last certification date' do
        yesterday = create(:certification, last_certification_date: Date.yesterday, customer: customer).
          last_certification_date.strftime("%m/%d/%Y")
        today = create(:certification, last_certification_date: Date.today, customer: customer).
          last_certification_date.strftime("%m/%d/%Y")
        tomorrow = create(:certification, last_certification_date: Date.tomorrow, customer: customer).
          last_certification_date.strftime("%m/%d/%Y")

        visit '/'
        click_link 'All Employee Certifications'

        # Ascending sort
        click_link 'Last Certification Date'
        column_data_should_be_in_order(yesterday, today, tomorrow)

        # Descending sort
        click_link 'Last Certification Date'
        column_data_should_be_in_order(tomorrow, today, yesterday)
      end

      it 'should sort by expiration date' do
        yesterday = create(:certification, expiration_date: Date.yesterday, customer: customer).
          expiration_date.strftime("%m/%d/%Y")
        today = create(:certification, expiration_date: Date.today, customer: customer).
          expiration_date.strftime("%m/%d/%Y")
        tomorrow = create(:certification, expiration_date: Date.tomorrow, customer: customer).
          expiration_date.strftime("%m/%d/%Y")

        visit '/'
        click_link 'All Employee Certifications'

        # Ascending sort
        click_link 'Expiration Date'
        column_data_should_be_in_order(yesterday, today, tomorrow)

        # Descending sort
        click_link 'Expiration Date'
        column_data_should_be_in_order(tomorrow, today, yesterday)
      end
    end

    context 'pagination' do
      before do
        login_as_certification_user(customer)
      end

      it 'should paginate' do
        55.times do
          create(:certification, customer: customer)
        end

        visit '/'
        click_link 'All Employee Certifications (55)'

        find 'table.sortable'

        page.all('table tr').count.should == 25 + 1
        within 'div.pagination' do
          page.should_not have_link 'Previous'
          page.should_not have_link '1'
          page.should have_link '2'
          page.should have_link '3'
          page.should have_link 'Next'

          click_link 'Next'
        end


        page.all('table tr').count.should == 25 + 1
        within 'div.pagination' do
          page.should have_link 'Previous'
          page.should have_link '1'
          page.should_not have_link '2'
          page.should have_link '3'
          page.should have_link 'Next'

          click_link 'Next'
        end


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

  describe 'Expired Certifications' do
    context 'when a certification user' do
      let!(:cpr_certification_type) do
        create(:certification_type,
               name: 'CPR',
               interval: Interval::ONE_YEAR.text,
               customer: customer
        )
      end

      let!(:truck_certification_type) do
        create(:certification_type,
               name: 'Level III Truck Inspection',
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

      let!(:not_expired_cpr_certification) do
        create(
          :certification,
          employee: employee,
          certification_type: cpr_certification_type,
          last_certification_date: Date.new(2005, 7, 8),
          expiration_date: Date.tomorrow,
          trainer: 'Trainer Tim',
          customer: employee.customer)
      end

      let!(:expired_truck_certification) do
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

      it 'should list expired employee certifications' do
        visit '/'
        page.should have_content 'Expired Certifications (1)'
        click_link 'Expired Certifications (1)'

        page.should have_content 'Expired Certifications'
        page.should have_content 'Total: 1'

        within 'table thead tr' do
          page.should have_link 'Certification Type'
          page.should have_link 'Interval'
          page.should have_link 'Units'
          page.should have_link 'Status'
          page.should have_link 'Employee'
          page.should have_link 'Trainer'
          page.should have_link 'Last Certification Date'
          page.should have_link 'Expiration Date'
        end

        within 'table tbody tr:nth-of-type(1)' do
          page.should have_link 'Level III Truck Inspection'
          page.should have_content '6 months'
          page.should have_content 'Expired'
          page.should have_content 'Brown, Joe'
          page.should have_content 'Trucker Joe'
          page.should have_content '12/10/2007'
          page.should have_content '06/10/2008'
        end
      end
    end

    context 'when an admin user' do
      let(:customer1) { create(:customer) }
      let(:customer2) { create(:customer) }

      let(:certification_type1) do
        create(:certification_type,
               name: 'CPR',
               customer: customer1
        )
      end

      let(:certification_type2) do
        create(:certification_type,
               name: 'Level III Truck Inspection',
               customer: customer2
        )
      end

      let(:employee1) do
        create(:employee,
               customer_id: customer1.id
        )
      end

      let(:employee2) do
        create(:employee,
               customer_id: customer2.id
        )
      end

      let!(:certification1) do
        create(
          :certification,
          employee: employee1,
          certification_type: certification_type1,
          expiration_date: Date.yesterday,
          customer: customer1)
      end

      let!(:certification2) do
        create(
          :certification,
          employee: employee2,
          certification_type: certification_type2,
          expiration_date: Date.yesterday,
          customer: customer2)
      end

      before do
        login_as_admin
      end

      it 'should show expired certification for all customers' do
        click_link 'Expired Certifications (2)'

        page.should have_content 'CPR'
        page.should have_content 'Level III Truck Inspection'
      end
    end

    context 'sorting' do
      before do
        login_as_certification_user(customer)
      end

      it 'should sort by certification type name' do
        zeta = create(:certification_type, name: 'zeta', customer: customer)
        beta = create(:certification_type, name: 'beta', customer: customer)
        alpha = create(:certification_type, name: 'alpha', customer: customer)
        create(:certification, certification_type: zeta, customer: customer, expiration_date: Date.yesterday)
        create(:certification, certification_type: beta, customer: customer, expiration_date: Date.yesterday)
        create(:certification, certification_type: alpha, customer: customer, expiration_date: Date.yesterday)

        visit '/'
        click_link 'Expired Certifications'

        # Ascending sort
        click_link 'Certification Type'
        column_data_should_be_in_order('alpha', 'beta', 'zeta')

        # Descending sort
        click_link 'Certification Type'
        column_data_should_be_in_order('zeta', 'beta', 'alpha')
      end

      it 'should sort by interval' do
        create(:certification, expiration_date: Date.yesterday,
               certification_type: create(:certification_type, interval: Interval::SIX_MONTHS.text, customer: customer))
        create(:certification, expiration_date: Date.yesterday,
               certification_type: create(:certification_type, interval: Interval::TWO_YEARS.text, customer: customer))
        create(:certification, expiration_date: Date.yesterday,
               certification_type: create(:certification_type, interval: Interval::ONE_YEAR.text, customer: customer))
        create(:certification, expiration_date: Date.yesterday,
               certification_type: create(:certification_type, interval: Interval::FIVE_YEARS.text, customer: customer))
        create(:certification, expiration_date: Date.yesterday,
               certification_type: create(:certification_type, interval: Interval::NOT_REQUIRED.text, customer: customer))
        create(:certification, expiration_date: Date.yesterday,
               certification_type: create(:certification_type, interval: Interval::THREE_YEARS.text, customer: customer))
        create(:certification, expiration_date: Date.yesterday,
               certification_type: create(:certification_type, interval: Interval::ONE_MONTH.text, customer: customer))
        create(:certification, expiration_date: Date.yesterday,
               certification_type: create(:certification_type, interval: Interval::THREE_MONTHS.text, customer: customer))

        visit '/'
        click_link 'Expired Certifications'

        # Ascending sort
        click_link 'Interval'
        column_data_should_be_in_order(
          Interval::ONE_MONTH.text,
          Interval::THREE_MONTHS.text,
          Interval::SIX_MONTHS.text,
          Interval::ONE_YEAR.text,
          Interval::TWO_YEARS.text,
          Interval::THREE_YEARS.text,
          Interval::FIVE_YEARS.text,
          Interval::NOT_REQUIRED.text
        )

        # Descending sort
        click_link 'Interval'
        column_data_should_be_in_order(
          Interval::NOT_REQUIRED.text,
          Interval::FIVE_YEARS.text,
          Interval::THREE_YEARS.text,
          Interval::TWO_YEARS.text,
          Interval::ONE_YEAR.text,
          Interval::SIX_MONTHS.text,
          Interval::THREE_MONTHS.text,
          Interval::ONE_MONTH.text
        )
      end

      it 'should sort by employee' do
        zeta = create(:certification, expiration_date: Date.yesterday,
                      employee: create(:employee, last_name: 'zeta', first_name: 'a'), customer: customer)
        beta = create(:certification, expiration_date: Date.yesterday,
                      employee: create(:employee, last_name: 'beta', first_name: 'a'), customer: customer)
        alpha = create(:certification, expiration_date: Date.yesterday,
                       employee: create(:employee, last_name: 'alpha', first_name: 'a'), customer: customer)

        visit '/'
        click_link 'Expired Certifications'

        # Ascending sort
        click_link 'Employee'
        column_data_should_be_in_order(alpha.employee.last_name, beta.employee.last_name, zeta.employee.last_name)

        # Descending sort
        click_link 'Employee'
        column_data_should_be_in_order(zeta.employee.last_name, beta.employee.last_name, alpha.employee.last_name)
      end

      it 'should sort by trainer' do
        zeta = create(:certification, trainer: 'zeta', customer: customer, expiration_date: Date.yesterday,)
        beta = create(:certification, trainer: 'beta', customer: customer, expiration_date: Date.yesterday,)
        alpha = create(:certification, trainer: 'alpha', customer: customer, expiration_date: Date.yesterday,)

        visit '/'
        click_link 'Expired Certifications'

        # Ascending sort
        click_link 'Trainer'
        column_data_should_be_in_order(alpha.trainer, beta.trainer, zeta.trainer)

        # Descending sort
        click_link 'Trainer'
        column_data_should_be_in_order(zeta.trainer, beta.trainer, alpha.trainer)
      end

      it 'should sort by last certification date' do
        yesterday = create(:certification, last_certification_date: Date.yesterday, customer: customer, expiration_date: Date.yesterday).
          last_certification_date.strftime("%m/%d/%Y")
        today = create(:certification, last_certification_date: Date.today, customer: customer, expiration_date: Date.yesterday).
          last_certification_date.strftime("%m/%d/%Y")
        tomorrow = create(:certification, last_certification_date: Date.tomorrow, customer: customer, expiration_date: Date.yesterday).
          last_certification_date.strftime("%m/%d/%Y")

        visit '/'
        click_link 'Expired Certifications'

        # Ascending sort
        click_link 'Last Certification Date'
        column_data_should_be_in_order(yesterday, today, tomorrow)

        # Descending sort
        click_link 'Last Certification Date'
        column_data_should_be_in_order(tomorrow, today, yesterday)
      end

      it 'should sort by expiration date' do
        yesterday = create(:certification, expiration_date: Date.yesterday, customer: customer).
          expiration_date.strftime("%m/%d/%Y")
        today = create(:certification, expiration_date: Date.today, customer: customer).
          expiration_date.strftime("%m/%d/%Y")
        last_month = create(:certification, expiration_date: Date.yesterday-30, customer: customer).
          expiration_date.strftime("%m/%d/%Y")

        visit '/'
        click_link 'Expired Certifications'

        # Ascending sort
        click_link 'Expiration Date'
        column_data_should_be_in_order(last_month, yesterday, today)

        # Descending sort
        click_link 'Expiration Date'
        column_data_should_be_in_order(today, yesterday, last_month)
      end
    end

    context 'pagination' do
      before do
        login_as_certification_user(customer)
      end

      it 'should paginate' do
        55.times do
          create(:certification, customer: customer, expiration_date: Date.yesterday)
        end

        visit '/'
        click_link 'Expired Certifications (55)'

        find 'table.sortable'

        page.all('table tr').count.should == 25 + 1
        within 'div.pagination' do
          page.should_not have_link 'Previous'
          page.should_not have_link '1'
          page.should have_link '2'
          page.should have_link '3'
          page.should have_link 'Next'

          click_link 'Next'
        end


        page.all('table tr').count.should == 25 + 1
        within 'div.pagination' do
          page.should have_link 'Previous'
          page.should have_link '1'
          page.should_not have_link '2'
          page.should have_link '3'
          page.should have_link 'Next'

          click_link 'Next'
        end


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

  describe 'Expiring Certifications' do
    context 'when a certification user' do
      let!(:cpr_certification_type) do
        create(:certification_type,
               name: 'CPR',
               interval: Interval::ONE_YEAR.text,
               customer: customer
        )
      end

      let!(:truck_certification_type) do
        create(:certification_type,
               name: 'Level III Truck Inspection',
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

      let!(:not_expiring_cpr_certification) do
        create(
          :certification,
          employee: employee,
          certification_type: cpr_certification_type,
          last_certification_date: Date.new(2005, 7, 8),
          expiration_date: Date.today,
          trainer: 'Trainer Tim',
          customer: employee.customer)
      end

      let!(:expiring_truck_certification) do
        create(
          :certification,
          employee: employee,
          certification_type: truck_certification_type,
          last_certification_date: Date.new(2007, 12, 10),
          expiration_date: Date.tomorrow,
          trainer: 'Trucker Joe',
          customer: employee.customer)
      end

      before do
        login_as_certification_user(customer)
      end

      it 'should list expiring employee certifications' do
        visit '/'
        page.should have_content 'Certifications Expiring Soon (1)'
        click_link 'Certifications Expiring Soon (1)'

        page.should have_content 'Certifications Expiring Soon'
        page.should have_content 'Total: 1'

        within 'table thead tr' do
          page.should have_link 'Certification Type'
          page.should have_link 'Interval'
          page.should have_link 'Units'
          page.should have_link 'Status'
          page.should have_link 'Employee'
          page.should have_link 'Trainer'
          page.should have_link 'Last Certification Date'
          page.should have_link 'Expiration Date'
        end

        within 'table tbody tr:nth-of-type(1)' do
          page.should have_link 'Level III Truck Inspection'
          page.should have_content '6 months'
          page.should have_content 'Warning'
          page.should have_content 'Brown, Joe'
          page.should have_content 'Trucker Joe'
          page.should have_content '12/10/2007'
          page.should have_content Date.tomorrow.strftime("%m/%d/%Y")
        end
      end
    end

    context 'when an admin user' do
      let(:customer1) { create(:customer) }
      let(:customer2) { create(:customer) }

      let(:certification_type1) do
        create(:certification_type,
               name: 'CPR',
               customer: customer1
        )
      end

      let(:certification_type2) do
        create(:certification_type,
               name: 'Level III Truck Inspection',
               customer: customer2
        )
      end

      let(:employee1) do
        create(:employee,
               customer_id: customer1.id
        )
      end

      let(:employee2) do
        create(:employee,
               customer_id: customer2.id
        )
      end

      let!(:certification1) do
        create(
          :certification,
          employee: employee1,
          certification_type: certification_type1,
          expiration_date: Date.tomorrow,
          customer: customer1)
      end

      let!(:certification2) do
        create(
          :certification,
          employee: employee2,
          certification_type: certification_type2,
          expiration_date: Date.tomorrow,
          customer: customer2)
      end

      before do
        login_as_admin
      end

      it 'should show expiring certifications for all customers' do
        click_link 'Certifications Expiring Soon (2)'

        page.should have_content 'CPR'
        page.should have_content 'Level III Truck Inspection'
      end
    end

    context 'sorting' do
      before do
        login_as_certification_user(customer)
      end

      it 'should sort by certification type name' do
        zeta = create(:certification_type, name: 'zeta', customer: customer)
        beta = create(:certification_type, name: 'beta', customer: customer)
        alpha = create(:certification_type, name: 'alpha', customer: customer)
        create(:certification, certification_type: zeta, customer: customer, expiration_date: Date.tomorrow)
        create(:certification, certification_type: beta, customer: customer, expiration_date: Date.tomorrow)
        create(:certification, certification_type: alpha, customer: customer, expiration_date: Date.tomorrow)

        visit '/'
        click_link 'Certifications Expiring Soon '

        # Ascending sort
        click_link 'Certification Type'
        column_data_should_be_in_order('alpha', 'beta', 'zeta')

        # Descending sort
        click_link 'Certification Type'
        column_data_should_be_in_order('zeta', 'beta', 'alpha')
      end

      it 'should sort by interval' do
        create(:certification, expiration_date: Date.tomorrow,
               certification_type: create(:certification_type, interval: Interval::SIX_MONTHS.text, customer: customer))
        create(:certification, expiration_date: Date.tomorrow,
               certification_type: create(:certification_type, interval: Interval::TWO_YEARS.text, customer: customer))
        create(:certification, expiration_date: Date.tomorrow,
               certification_type: create(:certification_type, interval: Interval::ONE_YEAR.text, customer: customer))
        create(:certification, expiration_date: Date.tomorrow,
               certification_type: create(:certification_type, interval: Interval::FIVE_YEARS.text, customer: customer))
        create(:certification, expiration_date: Date.tomorrow,
               certification_type: create(:certification_type, interval: Interval::NOT_REQUIRED.text, customer: customer))
        create(:certification, expiration_date: Date.tomorrow,
               certification_type: create(:certification_type, interval: Interval::THREE_YEARS.text, customer: customer))
        create(:certification, expiration_date: Date.tomorrow,
               certification_type: create(:certification_type, interval: Interval::ONE_MONTH.text, customer: customer))
        create(:certification, expiration_date: Date.tomorrow,
               certification_type: create(:certification_type, interval: Interval::THREE_MONTHS.text, customer: customer))

        visit '/'
        click_link 'Certifications Expiring Soon'

        # Ascending sort
        click_link 'Interval'
        column_data_should_be_in_order(
          Interval::ONE_MONTH.text,
          Interval::THREE_MONTHS.text,
          Interval::SIX_MONTHS.text,
          Interval::ONE_YEAR.text,
          Interval::TWO_YEARS.text,
          Interval::THREE_YEARS.text,
          Interval::FIVE_YEARS.text,
          Interval::NOT_REQUIRED.text
        )

        # Descending sort
        click_link 'Interval'
        column_data_should_be_in_order(
          Interval::NOT_REQUIRED.text,
          Interval::FIVE_YEARS.text,
          Interval::THREE_YEARS.text,
          Interval::TWO_YEARS.text,
          Interval::ONE_YEAR.text,
          Interval::SIX_MONTHS.text,
          Interval::THREE_MONTHS.text,
          Interval::ONE_MONTH.text
        )
      end

      it 'should sort by employee' do
        zeta = create(:certification, expiration_date: Date.tomorrow,
                      employee: create(:employee, last_name: 'zeta', first_name: 'a'), customer: customer)
        beta = create(:certification, expiration_date: Date.tomorrow,
                      employee: create(:employee, last_name: 'beta', first_name: 'a'), customer: customer)
        alpha = create(:certification, expiration_date: Date.tomorrow,
                       employee: create(:employee, last_name: 'alpha', first_name: 'a'), customer: customer)

        visit '/'
        click_link 'Certifications Expiring Soon '

        # Ascending sort
        click_link 'Employee'
        column_data_should_be_in_order(alpha.employee.last_name, beta.employee.last_name, zeta.employee.last_name)

        # Descending sort
        click_link 'Employee'
        column_data_should_be_in_order(zeta.employee.last_name, beta.employee.last_name, alpha.employee.last_name)
      end

      it 'should sort by trainer' do
        zeta = create(:certification, trainer: 'zeta', customer: customer, expiration_date: Date.tomorrow,)
        beta = create(:certification, trainer: 'beta', customer: customer, expiration_date: Date.tomorrow,)
        alpha = create(:certification, trainer: 'alpha', customer: customer, expiration_date: Date.tomorrow,)

        visit '/'
        click_link 'Certifications Expiring Soon '

        # Ascending sort
        click_link 'Trainer'
        column_data_should_be_in_order(alpha.trainer, beta.trainer, zeta.trainer)

        # Descending sort
        click_link 'Trainer'
        column_data_should_be_in_order(zeta.trainer, beta.trainer, alpha.trainer)
      end

      it 'should sort by last certification date' do
        tomorrow = create(:certification, last_certification_date: Date.tomorrow, customer: customer, expiration_date: Date.tomorrow).
          last_certification_date.strftime("%m/%d/%Y")
        today = create(:certification, last_certification_date: Date.today, customer: customer, expiration_date: Date.tomorrow).
          last_certification_date.strftime("%m/%d/%Y")
        yesterday = create(:certification, last_certification_date: Date.yesterday, customer: customer, expiration_date: Date.tomorrow).
          last_certification_date.strftime("%m/%d/%Y")

        visit '/'
        click_link 'Certifications Expiring Soon'

        # Ascending sort
        click_link 'Last Certification Date'
        column_data_should_be_in_order(yesterday, today, tomorrow)

        # Descending sort
        click_link 'Last Certification Date'
        column_data_should_be_in_order(tomorrow, today, yesterday)
      end

      it 'should sort by expiration date' do
        tomorrow = create(:certification, expiration_date: Date.tomorrow, customer: customer).
          expiration_date.strftime("%m/%d/%Y")
        in_two_days = create(:certification, expiration_date: Date.today+2, customer: customer).
          expiration_date.strftime("%m/%d/%Y")
        in_three_days = create(:certification, expiration_date: Date.today+3, customer: customer).
          expiration_date.strftime("%m/%d/%Y")

        visit '/'
        click_link 'Certifications Expiring Soon '

        # Ascending sort
        click_link 'Expiration Date'
        column_data_should_be_in_order(tomorrow, in_two_days, in_three_days)

        # Descending sort
        click_link 'Expiration Date'
        column_data_should_be_in_order(in_three_days, in_two_days, tomorrow)
      end
    end

    context 'pagination' do
      before do
        login_as_certification_user(customer)
      end

      it 'should paginate' do
        55.times do
          create(:certification, customer: customer, expiration_date: Date.tomorrow)
        end

        visit '/'
        click_link 'Certifications Expiring Soon (55)'

        find 'table.sortable'

        page.all('table tr').count.should == 25 + 1
        within 'div.pagination' do
          page.should_not have_link 'Previous'
          page.should_not have_link '1'
          page.should have_link '2'
          page.should have_link '3'
          page.should have_link 'Next'

          click_link 'Next'
        end


        page.all('table tr').count.should == 25 + 1
        within 'div.pagination' do
          page.should have_link 'Previous'
          page.should have_link '1'
          page.should_not have_link '2'
          page.should have_link '3'
          page.should have_link 'Next'

          click_link 'Next'
        end


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

  describe 'Units Based Certifications' do
    context 'when a certification user' do
      before do
        cpr_certification_type =
          create(:certification_type,
                 name: 'CPR',
                 interval: Interval::ONE_YEAR.text,
                 customer: customer
          )

        truck_certification_type =
          create(:units_based_certification_type,
                 name: 'Level III Truck Inspection',
                 units_required: 100,
                 interval: Interval::SIX_MONTHS.text,
                 customer: customer
          )

        employee =
          create(:employee,
                 employee_number: 'JB3',
                 first_name: 'Joe',
                 last_name: 'Brown',
                 location: create(:location, name: 'Denver'),
                 customer_id: customer.id
          )

        date_based_cpr_certification =
          create(
            :certification,
            employee: employee,
            certification_type: cpr_certification_type,
            customer: employee.customer)

        units_based_truck_certification =
          create(
            :certification,
            employee: employee,
            certification_type: truck_certification_type,
            last_certification_date: Date.yesterday,
            expiration_date: Date.tomorrow,
            units_achieved: 13,
            trainer: 'Trucker Joe',
            customer: employee.customer)

        login_as_certification_user(customer)
      end

      it 'should list units based employee certifications' do
        visit '/'
        page.should have_content 'Units Based Certifications (1)'
        click_link 'Units Based Certifications (1)'

        page.should have_content 'Units Based Certifications'
        page.should have_content 'Total: 1'

        within 'table thead tr' do
          page.should have_link 'Certification Type'
          page.should have_link 'Interval'
          page.should have_link 'Units'
          page.should have_link 'Status'
          page.should have_link 'Employee'
          page.should have_link 'Trainer'
          page.should have_link 'Last Certification Date'
          page.should have_link 'Expiration Date'
        end

        within 'table tbody tr:nth-of-type(1)' do
          page.should have_link 'Level III Truck Inspection'
          page.should have_content '6 months'
          page.should have_content '13 of 100'
          page.should have_content 'Pending'
          page.should have_content 'Brown, Joe'
          page.should have_content 'Trucker Joe'
          page.should have_content Date.yesterday.strftime("%m/%d/%Y")
          page.should have_content Date.tomorrow.strftime("%m/%d/%Y")
        end
      end
    end
  end

  describe 'Recertification Required Certifications' do
    context 'when a certification user' do
      before do
        cpr_certification_type =
          create(:units_based_certification_type,
                 name: 'CPR',
                 units_required: 100,
                 interval: Interval::ONE_YEAR.text,
                 customer: customer
          )

        truck_certification_type =
          create(:units_based_certification_type,
                 name: 'Level III Truck Inspection',
                 units_required: 100,
                 interval: Interval::SIX_MONTHS.text,
                 customer: customer
          )

        employee =
          create(:employee,
                 employee_number: 'JB3',
                 first_name: 'Joe',
                 last_name: 'Brown',
                 location: create(:location, name: 'Denver'),
                 customer_id: customer.id
          )

        units_based_truck_certification_requiring_recertification =
          create(
            :certification,
            employee: employee,
            certification_type: truck_certification_type,
            last_certification_date: Date.new(2009, 1, 1),
            expiration_date: Date.new(2010, 1, 1),
            units_achieved: 13,
            trainer: 'Trucker Joe',
            customer: employee.customer)

        valid_units_based_truck_certification =
          create(
            :certification,
            employee: employee,
            certification_type: cpr_certification_type,
            last_certification_date: Date.yesterday,
            expiration_date: Date.tomorrow,
            units_achieved: 101,
            trainer: 'Trucker Jim',
            customer: employee.customer)

        login_as_certification_user(customer)
      end

      it 'should list recertification required employee certifications' do
        visit '/'
        page.should have_content 'Recertification Required Certifications (1)'
        click_link 'Recertification Required Certifications (1)'

        page.should have_content 'Recertification Required Certifications'
        page.should have_content 'Total: 1'

        within 'table thead tr' do
          page.should have_link 'Certification Type'
          page.should have_link 'Interval'
          page.should have_link 'Units'
          page.should have_link 'Status'
          page.should have_link 'Employee'
          page.should have_link 'Trainer'
          page.should have_link 'Last Certification Date'
          page.should have_link 'Expiration Date'
        end

        within 'table tbody tr:nth-of-type(1)' do
          page.should have_link 'Level III Truck Inspection'
          page.should have_content '6 months'
          page.should have_content '13 of 100'
          page.should have_content 'Recertify'
          page.should have_content 'Brown, Joe'
          page.should have_content 'Trucker Joe'
          page.should have_content '01/01/2009'
          page.should have_content '01/01/2010'
        end
      end
    end
  end
end