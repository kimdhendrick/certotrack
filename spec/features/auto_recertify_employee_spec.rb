require 'spec_helper'

describe 'Auto Recertify', slow: true do
  let(:customer) { create(:customer) }
  let(:certification_type) { create(:units_based_certification_type, customer: customer, name: 'ScrumMaster') }

  describe 'Show Certification Type page' do

    before do
      @certification = create(:units_based_certification, certification_type: certification_type, customer: customer)
      login_as_certification_user(customer)
    end

    context 'when certification type is units based' do
      context 'when no certifications exist for the certification type' do
        before { Certification.destroy_all }

        it 'should not show the Auto Recertify button' do
          visit certification_type_path(certification_type)
          page.should_not have_link('Auto Recertify')
        end
      end

      context 'when no valid certifications exist for the certification type' do
        before { @certification.update_attribute(:units_achieved, certification_type.units_required - 1) }

        it 'should not show the Auto Recertify button' do
          visit certification_type_path(certification_type)
          page.should_not have_link('Auto Recertify')
        end
      end

      context 'when a valid certifications exists for the certification type' do
        it 'should show the Auto Recertify button' do
          visit certification_type_path(certification_type)
          page.should have_link 'Auto Recertify'
        end
      end
    end

    context 'when certification type is not units based' do
      let(:certification_type) { create(:date_based_certification_type, customer: customer) }

      before do
        @certification = create(:date_based_certification,
                                certification_type: certification_type,
                                expiration_date: 61.days.from_now,
                                customer: customer)
      end

      it 'should not show the Auto Recertify button' do
        @certification.status.should == Status::VALID
        visit certification_type_path(certification_type)
        page.should_not have_link('Auto Recertify')
      end
    end
  end

  describe 'Auto Recertify page' do
    before do
      @certification1 = create(:units_based_certification, certification_type: certification_type, customer: customer, trainer: 'Doe, Jane', expiration_date: Time.local(2013, 12, 1))
      @certification2 = create(:units_based_certification, certification_type: certification_type, customer: customer)
      login_as_certification_user(customer)
    end

    it 'should behave' do
      visit certification_type_path(certification_type)
      click_link 'Auto Recertify'

      # Page Headers
      page.should have_selector('h1', text: 'Valid Certifications')
      page.should have_selector('h2', text: 'ScrumMaster')

      # Links
      page.should have_link('Home', href: dashboard_path)
      page.should have_link('Search Certifications', href: search_certifications_path)

      # Column Headers
      page.should have_selector('th', text: 'Select')
      page.should have_selector('th', text: 'Certification Type')
      page.should have_selector('th', text: 'Interval')
      page.should have_selector('th', text: 'Status')
      page.should have_selector('th', text: 'Employee')
      page.should have_selector('th', text: 'Trainer')
      page.should have_selector('th', text: 'Last Certification Date')
      page.should have_selector('th', text: 'Expiration Date')

      # Row Values

      within('tbody tr:first-child') do
        page.should have_selector('td.certification_type', text: 'ScrumMaster')
        page.should have_selector('td.interval', text: 'Annually')
        page.should have_selector('td.status', text: 'Valid')
        page.should have_selector('td.employee', text: 'Smith, John')
        page.should have_selector('td.trainer', text: 'Doe, Jane')
        page.should have_selector('td.last_certification_date', text: '05/15/2013')
        page.should have_selector('td.expiration_date', text: '12/01/2013')
      end

      within('tbody tr:nth-child(2)') do
        page.should have_selector('td.certification_type', text: 'ScrumMaster')
        page.should have_selector('td.interval', text: 'Annually')
        page.should have_selector('td.status', text: 'Valid')
        page.should have_selector('td.employee', text: 'Smith, John')
        page.should have_selector('td.trainer', text: 'Trainer')
        page.should have_selector('td.last_certification_date', text: '05/15/2013')
        page.should have_selector('td.expiration_date', text: '')
      end

      # Form Values
      page.should have_unchecked_field("certification_#{@certification1.id}")
      page.should have_unchecked_field("certification_#{@certification2.id}")
      page.should have_button('Recertify')

      # Submit Form
      check("certification_#{@certification1.id}")
      click_button('Recertify')

      page.should have_content('Show Certification Type')
      page.should have_content('ScrumMaster')
      page.should have_content('Auto Recertify successful.')
    end
  end
end