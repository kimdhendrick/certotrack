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
end