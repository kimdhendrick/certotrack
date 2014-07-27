require 'spec_helper'

describe 'Training Event', slow: true do
  let(:customer) { create(:customer) }

  before do
    indian_hills = create(:location, name: 'Indian Hills')
    @sean = create(:employee, employee_number: 'SLB321', first_name: 'Sean', last_name: 'LeManzo', location: indian_hills, customer: customer)

    golden = create(:location, name: 'Golden')
    @kim = create(:employee, employee_number: 'KB999', first_name: 'Kim', last_name: 'Arnesbay', location: golden, customer: customer)

    highlands_ranch = create(:location, name: 'Highlands Ranch')
    @david = create(:employee, employee_number: 'DM876', first_name: 'David', last_name: 'Madman', location: highlands_ranch, customer: customer)

    @fire_fighter_certification_type = create(:certification_type, name: 'Fire Fighter I', interval: Interval::ONE_YEAR.text, customer: customer)
    create(:certification_type, name: 'Level I Truck Inspector', interval: Interval::ONE_MONTH.text, customer: customer)
    create(:certification_type, name: 'CPR', interval: Interval::SIX_MONTHS.text, customer: customer)

    login_as_certification_user(customer)
  end

  it 'should let user certify employees for training event', js: true do
    visit dashboard_path
    click_on 'Create Training Event'

    page.should have_content 'Create Training Event - Select Employees'

    within 'table thead tr' do
      page.should have_content 'Select'
      page.should have_content 'Employee Number'
      page.should have_content 'First Name'
      page.should have_content 'Last Name'
      page.should have_content 'Location'
    end

    within 'table tbody tr:nth-of-type(1)' do
      page.should have_content 'David'
    end

    within 'table tbody tr:nth-of-type(2)' do
      page.should have_content 'KB999'
      page.should have_content 'Kim'
      page.should have_content 'Arnesbay'
      page.should have_content 'Golden'

      check 'employee_ids[]'
    end

    within 'table tbody tr:nth-of-type(3)' do
      page.should have_content 'SLB321'
      page.should have_content 'Sean'
      page.should have_content 'LeManzo'
      page.should have_content 'Indian Hills'

      check 'employee_ids[]'
    end

    page.should have_button 'Next'

    click_on 'Next'

    page.should have_content 'Create Training Event - Select Certification Types'

    within 'table thead tr' do
      page.should have_content 'Select'
      page.should have_content 'Name'
      page.should have_content 'Interval'
    end

    within 'table tbody tr:nth-of-type(1)' do
      page.should have_content 'CPR'
      page.should have_content '6 months'
    end

    within 'table tbody tr:nth-of-type(2)' do
      page.should have_content 'Fire Fighter I'
      page.should have_content 'Annually'

      check 'certification_type_ids[]'
    end

    within 'table tbody tr:nth-of-type(3)' do
      page.should have_content 'Level I Truck Inspector'
      page.should have_content '1 month'
    end

    page.should have_button 'Next'

    click_on 'Next'

    page.should have_content 'Create Training Event'
    page.should have_content 'Please confirm that these employees'

    within '[data-employee-list] table thead tr' do
      page.should have_content 'Employee Number'
      page.should have_content 'First Name'
      page.should have_content 'Last Name'
      page.should have_content 'Location'
    end

    within '[data-employee-list] table tbody tr:nth-of-type(1)' do
      page.should have_content 'SLB321'
      page.should have_content 'Sean'
      page.should have_content 'LeManzo'
      page.should have_content 'Indian Hills'
    end

    within '[data-employee-list] table tbody tr:nth-of-type(2)' do
      page.should have_content 'KB999'
      page.should have_content 'Kim'
      page.should have_content 'Arnesbay'
      page.should have_content 'Golden'
    end

    page.should have_content 'Will be registered for these certification types'

    within '[data-certification-type-list] table thead tr' do
      page.should have_content 'Name'
      page.should have_content 'Interval'
    end

    within '[data-certification-type-list] table tbody tr:nth-of-type(1)' do
      page.should have_content 'Fire Fighter I'
      page.should have_content 'Annually'
    end

    page.should have_button 'Save'

    fill_in 'Trainer', with: 'Trainer Joe'
    fill_in 'Certification Date', with: '11/08/2013'
    fill_in 'Comments', with: 'Just for fun'

    click_on 'Save'

    page.should have_content 'Create Training Event - Confirmation'
    page.should have_content 'Training event has been created, please print out this page for your records.'

    within '[data-employee-list] table thead tr' do
      page.should have_content 'Employee Number'
      page.should have_content 'First Name'
      page.should have_content 'Last Name'
      page.should have_content 'Location'
    end

    within '[data-employee-list] table tbody tr:nth-of-type(1)' do
      page.should have_content 'SLB321'
      page.should have_content 'Sean'
      page.should have_content 'LeManzo'
      page.should have_content 'Indian Hills'
    end

    within '[data-employee-list] table tbody tr:nth-of-type(2)' do
      page.should have_content 'KB999'
      page.should have_content 'Kim'
      page.should have_content 'Arnesbay'
      page.should have_content 'Golden'
    end

    within '[data-certification-type-list] table thead tr' do
      page.should have_content 'Name'
      page.should have_content 'Interval'
    end

    within '[data-certification-type-list] table tbody tr:nth-of-type(1)' do
      page.should have_content 'Fire Fighter I'
      page.should have_content 'Annually'
    end

    within '[data-details] table thead tr' do
      page.should have_content 'Trainer'
      page.should have_content 'Certification Date'
      page.should have_content 'Comments'
    end

    within '[data-details] table tbody tr:nth-of-type(1)' do
      page.should have_content 'Trainer Joe'
      page.should have_content '11/08/2013'
      page.should have_content 'Just for fun'
    end

    page.should have_link 'Home'
    page.should have_link 'Search Certifications'

    Certification.count.should == 2
  end
end