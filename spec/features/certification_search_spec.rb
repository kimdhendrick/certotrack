require 'spec_helper'

describe 'Certification Search' do

  let(:customer) { create(:customer) }

  context 'when a certification user' do
    before do
      login_as_certification_user(customer)

      cpr = create(
        :certification_type,
        units_required: 20,
        customer: customer,
        name: 'CPR'
      )

      routine_exam = create(
        :certification_type,
        customer: customer,
        name: 'Routine Examination'
      )

      denver = create(
        :location,
        name: 'Denver',
        customer: customer
      )

      bob = create(
        :employee,
        first_name: 'Bob',
        last_name: 'Smith',
        location: denver
      )

      lone_tree = create(
        :location,
        name: 'Lone Tree',
        customer: customer
      )

      jill = create(
        :employee,
        first_name: 'Jill',
        last_name: 'Jones',
        location: lone_tree
      )

      create(
        :certification,
        certification_type: cpr,
        units_achieved: 15,
        employee: bob
      )

      create(
        :certification,
        certification_type: routine_exam,
        employee: jill
      )
    end

    it 'should show Search Certifications page', js: true do
      _navigate_to_search

      page.should have_content 'Search Certifications'
      fill_in 'Employee or Certification Type Name contains:', with: 'CPR'
      click_on 'Search'

      page.should have_content 'Search Certifications'
      _assert_report_headers_are_correct
      find 'table.sortable'
      page.should have_link 'CPR'
      page.should_not have_link 'Routine Examination'

      _navigate_to_search

      fill_in 'Employee or Certification Type Name contains:', with: 'Jill'
      click_on 'Search'

      page.should have_link 'Jones, Jill'
      page.should_not have_link 'Smith, Bob'

      _navigate_to_search

      select 'Lone Tree', from: 'location_id'
      click_on 'Search'

      page.should have_link 'Jones, Jill'
      page.should_not have_link 'Smith, Bob'

      _navigate_to_search

      select 'Denver', from: 'location_id'
      click_on 'Search'

      page.should have_link 'Smith, Bob'
      page.should_not have_link 'Jones, Jill'

      _navigate_to_search

      select 'Units Based', from: 'certification_type'
      click_on 'Search'

      page.should have_link 'CPR'
      page.should_not have_link 'Routine Exam'

      select 'Date Based', from: 'certification_type'
      click_on 'Search'

      page.should have_link 'Routine Exam'
      page.should_not have_link 'CPR'
    end

    it 'should search and sort simultaneously' do
      _navigate_to_search

      fill_in 'Employee or Certification Type Name contains:', with: 'CPR'
      click_on 'Search'

      page.should have_link 'CPR'
      page.should_not have_link 'Routine Examination'

      click_on 'Certification Type'

      page.should have_link 'CPR'
      page.should_not have_link 'Routine Examination'
    end
  end

  def _navigate_to_search
    visit '/'
    within '[data-certification-search-form]' do
      click_on 'Search'
    end
  end

  def _assert_report_headers_are_correct
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
  end
end

