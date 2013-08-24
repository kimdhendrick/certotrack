require 'spec_helper'

describe 'Certification Type', js: true do

  describe 'Create Certification Type' do
    before do
      login_as_certification_user
    end

    it 'should create new units based certification type' do
      visit '/'
      click_link 'Create Certification Type'

      page.should have_content 'Create Certification Type'
      page.should have_link 'Home'

      #Different from CToG, but more consistent, usable:
      #page.should have_link 'Search Certification Types'

      page.should have_content 'Name'
      page.should have_content 'Interval'
      page.should have_content 'Required Units'

      fill_in 'Name', with: 'Periodic Inspection'
      fill_in 'Required Units', with: 32
      select '5 years', from: 'Interval'

      click_on 'Create'

      page.should have_content 'Show Certification Type'

      page.should have_content 'Name Periodic Inspection'
      page.should have_content 'Required Units 32'
      page.should have_content 'Interval 5 years'
    end
  end

  describe 'Show Certification Type' do
    before do
      login_as_certification_user
    end

    it 'should render show certification type page' do
      certification_type = create_certification_type(
        name: 'CPR',
        interval: Interval::SIX_MONTHS.text,
        customer: @customer
      )

      visit certification_type_path certification_type.id

      page.should have_link 'Home'
      page.should have_link 'All Certification Types'
      page.should have_link 'Create Certification Type'

      page.should have_content 'Name CPR'
      page.should have_content 'Interval 6 months'
      page.should_not have_content 'Required Units'

      page.should have_link 'Edit'
      page.should have_link 'Delete'
    end

    it 'should render show certification type page for units based' do
      certification_type = create_certification_type(
        name: 'CPR',
        interval: Interval::SIX_MONTHS.text,
        units_required: 123,
        customer: @customer
      )

      visit certification_type_path certification_type.id

      page.should have_link 'Home'
      page.should have_link 'All Certification Types'
      page.should have_link 'Create Certification Type'

      page.should have_content 'Name CPR'
      page.should have_content 'Interval 6 months'
      page.should have_content 'Required Units 123'

      page.should have_link 'Edit'
      page.should have_link 'Delete'
    end
  end

  describe 'Update Certification Type' do
    before do
      login_as_certification_user
    end

    it 'should update existing certification type' do
      certification_type = create_certification_type(
        name: 'CPR',
        interval: Interval::SIX_MONTHS.text,
        customer: @customer
      )

      visit certification_type_path certification_type.id

      click_on 'Edit'

      page.should have_content 'Edit Certification Type'
      page.should have_link 'Home'
      page.should have_link 'All Certification Types'
      page.should have_link 'Create Certification Type'

      page.should have_link 'Delete'

      page.should have_content 'Name'
      page.should have_content 'Interval'
      page.should have_content 'Required Units'

      fill_in 'Name', with: 'Emergency Responder'
      fill_in 'Required Units', with: '13'
      select 'Annually', from: 'Interval'

      click_on 'Update'

      page.should have_content 'Show Certification Type'
      page.should have_content 'Name Emergency Responder'
      page.should have_content 'Interval Annually'
      page.should have_content 'Required Units 13'
    end
  end

  describe 'Delete Certification Type' do
    before do
      login_as_certification_user
    end

    it 'should delete existing certification_type' do
      certification_type = create_certification_type(
        customer: @customer,
        name: 'CPR'
      )

      visit certification_type_path certification_type.id

      page.should have_content 'Show Certification Type'
      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete?')
      alert.dismiss

      page.should have_content 'Show Certification Type'

      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete?')
      alert.accept

      page.should have_content 'All Certification Type'
      page.should have_content 'Certification Type was successfully deleted.'
    end
  end

  describe 'All Certification Type Report' do
    context 'when a certification user' do
      before do
        login_as_certification_user
      end

      it 'should show All Certification Types report' do
        create_certification_type(
          customer: @customer,
          name: 'CPR',
          interval: 'Annually',
          units_required: 0
        )

        create_certification_type(
          customer: @customer,
          name: 'Routine Exam',
          interval: '1 month',
          units_required: 99
        )

        visit '/'
        page.should have_content 'All Certification Types'
        click_link 'All Certification Types'

        page.should have_content 'All Certification Types'
        page.should have_content 'Total: 2'

        assert_report_headers_are_correct

        within 'table tbody tr:nth-of-type(1)' do
          page.should have_link 'CPR'
          page.should have_content 'Annually'
          page.should_not have_content '0'
        end

        within 'table tbody tr:nth-of-type(2)' do
          page.should have_link 'Routine Exam'
          page.should have_content '1 month'
          page.should have_content '99'
        end
      end
    end

    context 'when an admin user' do
      before do
        login_as_admin
      end

      it 'should show all certification types for all customers' do
        create_certification_type(name: 'CPR', customer: @customer)
        create_certification_type(name: 'Routine Exam', customer: @customer)
        create_certification_type(name: 'Special Test', customer: create_customer)

        click_link 'All Certification Types'

        page.should have_content 'CPR'
        page.should have_content 'Routine Exam'
        page.should have_content 'Special Test'
      end
    end

    context 'sorting' do
      before do
        login_as_certification_user
      end

      it 'should sort by name' do
        create_certification_type(name: 'zeta', customer: @customer)
        create_certification_type(name: 'beta', customer: @customer)
        create_certification_type(name: 'alpha', customer: @customer)

        visit '/'
        click_link 'All Certification Types'

        # Ascending sort
        click_link 'Name'
        column_data_should_be_in_order(['alpha', 'beta', 'zeta'])

        # Descending sort
        click_link 'Name'
        column_data_should_be_in_order(['zeta', 'beta', 'alpha'])
      end

      it 'should sort by interval' do
        create_certification_type(interval: Interval::SIX_MONTHS.text, customer: @customer)
        create_certification_type(interval: Interval::TWO_YEARS.text, customer: @customer)
        create_certification_type(interval: Interval::ONE_YEAR.text, customer: @customer)
        create_certification_type(interval: Interval::FIVE_YEARS.text, customer: @customer)
        create_certification_type(interval: Interval::NOT_REQUIRED.text, customer: @customer)
        create_certification_type(interval: Interval::THREE_YEARS.text, customer: @customer)
        create_certification_type(interval: Interval::ONE_MONTH.text, customer: @customer)
        create_certification_type(interval: Interval::THREE_MONTHS.text, customer: @customer)

        visit '/'
        click_link 'All Certification Types'

        # Ascending sort
        click_link 'Interval'
        column_data_should_be_in_order(
          [
            Interval::ONE_MONTH.text,
            Interval::THREE_MONTHS.text,
            Interval::SIX_MONTHS.text,
            Interval::ONE_YEAR.text,
            Interval::TWO_YEARS.text,
            Interval::THREE_YEARS.text,
            Interval::FIVE_YEARS.text,
            Interval::NOT_REQUIRED.text
          ]
        )

        # Descending sort
        click_link 'Interval'
        column_data_should_be_in_order(
          [
            Interval::NOT_REQUIRED.text,
            Interval::FIVE_YEARS.text,
            Interval::THREE_YEARS.text,
            Interval::TWO_YEARS.text,
            Interval::ONE_YEAR.text,
            Interval::SIX_MONTHS.text,
            Interval::THREE_MONTHS.text,
            Interval::ONE_MONTH.text
          ]
        )
      end
    end

    context 'pagination' do
      before do
        login_as_certification_user
      end

      it 'should paginate All Certification Types report' do
        55.times do
          create_certification_type(customer: @customer)
        end

        visit '/'
        click_link 'All Certification Types'

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

  describe 'Search Certification Types' do
    context 'when a certification user' do
      before do
        login_as_certification_user
      end

      it 'should show Search Certification Types page' do
        create_certification_type(
          customer: @customer,
          name: 'Unique Name'
        )

        create_certification_type(
          customer: @customer,
          name: 'Routine Examination'
        )

        visit '/'

        click_on 'Search Certification Types'

        page.should have_content 'Search Certification Types'

        fill_in 'Name contains:', with: 'Unique'

        click_on 'Search'

        page.should have_content 'Search Certification Types'

        assert_report_headers_are_correct

        find 'table.sortable'

        page.should have_link 'Unique Name'
        page.should_not have_link 'Routine Examination'
      end

      it 'should search and sort simultaneously' do
        create_certification_type(
          customer: @customer,
          name: 'Unique Name'
        )

        create_certification_type(
          customer: @customer,
          name: 'Routine Examination'
        )

        visit '/'
        click_on 'Search'

        page.should have_content 'Search Certification Types'

        fill_in 'Name contains:', with: 'Unique'

        click_on 'Search'

        page.should have_content 'Search Certification Types'

        assert_report_headers_are_correct

        find 'table.sortable'

        page.should have_link 'Unique Name'
        page.should_not have_link 'Routine Examination'

        click_on 'Name'

        page.should have_link 'Unique Name'
        page.should_not have_link 'Routine Examination'
      end
    end
  end

  def assert_report_headers_are_correct
    within 'table thead tr' do
      page.should have_link 'Name'
      page.should have_link 'Interval'
      page.should have_link 'Required Units'
    end
  end
end