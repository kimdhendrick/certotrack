require 'spec_helper'

describe 'Navigation', js:true do

  describe 'Equipment Links' do
    before do
      login_as_equipment_user
    end

    it 'navigates Home page' do
      visit root_path
      page.should have_content 'Welcome to CertoTrack'

      page.should have_link 'All Equipment (0)'
      page.should have_link 'Expired Equipment (0)'
      page.should have_link 'Equipment Expiring Soon (0)'
      page.should have_link 'Non-Inspectable Equipment'
      page.should have_link 'Create Equipment'

      click_link 'All Equipment'
      page.should have_content 'All Equipment'

      visit root_path
      click_link 'Create Equipment'
      page.should have_content 'Create Equipment'
    end

    it 'navigates All Equipment' do
      visit equipment_index_path
      page.should have_content 'All Equipment'

      click_link 'Home'
      page.should have_content 'Welcome to CertoTrack'

      visit equipment_index_path
      click_link 'Create Equipment'
      page.should have_content 'Create Equipment'

      visit equipment_index_path
      click_link 'Search Equipment'
      page.should have_content 'Search Equipment'
    end

    it 'navigates Expired Equipment List' do
      visit expired_equipment_path
      page.should have_content 'Expired Equipment List'

      click_link 'Home'
      page.should have_content 'Welcome to CertoTrack'

      visit expired_equipment_path
      click_link 'Create Equipment'
      page.should have_content 'Create Equipment'
    end

    it 'navigates Expiring Equipment List' do
      visit expiring_equipment_path
      page.should have_content 'Expiring Equipment List'

      click_link 'Home'
      page.should have_content 'Welcome to CertoTrack'

      visit expiring_equipment_path
      click_link 'Create Equipment'
      page.should have_content 'Create Equipment'
    end

    it 'navigates Non-Inspectable Equipment List' do
      visit noninspectable_equipment_path
      page.should have_content 'Non-Inspectable Equipment List'

      click_link 'Home'
      page.should have_content 'Welcome to CertoTrack'

      visit noninspectable_equipment_path
      click_link 'Create Equipment'
      page.should have_content 'Create Equipment'
    end

    it 'navigates Create Equipment' do
      visit new_equipment_path
      page.should have_content 'Create Equipment'

      click_link 'Home'
      page.should have_content 'Welcome to CertoTrack'

      visit new_equipment_path
      page.should have_content 'Create Equipment'

      click_link 'Search Equipment'
      page.should have_content 'Search Equipment'
    end

    it 'navigates Show Equipment' do
      equipment = create_equipment(customer: @customer)
      visit equipment_path equipment.id

      page.should have_link 'Home'
      page.should have_link 'All Equipment'
      page.should have_link 'Create Equipment'

      page.should have_link 'Edit'
      page.should have_link 'Delete'

      click_link 'Home'
      page.should have_content 'Welcome to CertoTrack'

      visit equipment_path equipment.id
      click_link 'All Equipment'
      page.should have_content 'All Equipment'

      visit equipment_path equipment.id
      click_link 'Search Equipment'
      page.should have_content 'Search Equipment'

      visit equipment_path equipment.id
      click_link 'Create Equipment'
      page.should have_content 'Create Equipment'

      visit equipment_path equipment.id
      click_link 'Edit'
      page.should have_content 'Edit Equipment'

      visit equipment_path equipment.id
      click_link 'Delete'
      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete?')
      alert.dismiss
    end

    it 'navigates Edit Equipment' do
      equipment = create_equipment(customer: @customer)
      visit equipment_path equipment.id

      click_on 'Edit'

      page.should have_link 'Home'
      page.should have_link 'All Equipment'
      page.should have_link 'Create Equipment'

      page.should have_link 'Delete'

      click_on 'Home'
      page.should have_content 'Welcome to CertoTrack'
      visit equipment_path equipment.id
      click_on 'Edit'
      click_on 'All Equipment'
      page.should have_content 'All Equipment'
      visit equipment_path equipment.id
      click_on 'Edit'
      click_on 'Create Equipment'
      page.should have_content 'Create Equipment'
    end

    it 'navigates Search Equipment' do
      visit root_path

      within '[data-equipment-search-form]' do
        click_on 'Search'
      end

      page.should have_content 'Search Equipment'

      click_link 'Home'
      page.should have_content 'Welcome to CertoTrack'

      within '[data-equipment-search-form]' do
        click_on 'Search'
      end

      page.should have_content 'Search Equipment'

      click_link 'Create Equipment'
      page.should have_content 'Create Equipment'
    end
  end

  describe 'Certification Links' do
    before do
      login_as_certification_user
    end

    it 'navigates Home page' do
      visit root_path
      page.should have_content 'Welcome to CertoTrack'

      page.should have_link 'Create Certification Type'
      page.should have_link 'All Certification Types'

      click_link 'Create Certification Type'
      page.should have_content 'Create Certification Type'
    end

    it 'navigates Create Certification Type' do
      visit new_certification_type_path
      page.should have_content 'Create Certification Type'
      page.should have_content 'All Certification Types'

      click_link 'Home'
      page.should have_content 'Welcome to CertoTrack'

      visit new_certification_type_path
      click_link 'All Certification Types'
      page.should have_content 'All Certification Types'
    end

    it 'navigates Show Certification Type' do
      certification_type = create_certification_type(customer: @customer)

      visit certification_type_path certification_type.id

      page.should have_content 'Show Certification Type'
      page.should have_link 'Home'
      page.should have_link 'All Certification Types'
      page.should have_link 'Create Certification Type'

      page.should have_link 'Edit'
      page.should have_link 'Delete'

      click_on 'Home'
      page.should have_content 'Welcome to CertoTrack'
      visit certification_type_path certification_type.id

      click_on 'All Certification Types'
      page.should have_content 'All Certification Types'
      visit certification_type_path certification_type.id

      visit certification_type_path certification_type.id
      click_on 'Create Certification Type'
      page.should have_content 'Create Certification Type'

      visit certification_type_path certification_type.id
      click_link 'Edit'
      page.should have_content 'Edit Certification Type'

      visit certification_type_path certification_type.id
      click_link 'Delete'
      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete?')
      alert.dismiss
    end

    it 'navigates Edit Certification Type' do
      certification_type = create_certification_type(customer: @customer)

      visit certification_type_path certification_type.id

      click_on 'Edit'
      page.should have_content 'Edit Certification Type'
      page.should have_link 'Home'
      page.should have_link 'All Certification Types'
      page.should have_link 'Create Certification Type'

      click_on 'Home'
      page.should have_content 'Welcome to CertoTrack'
      visit certification_type_path certification_type.id
      click_on 'Edit'
      click_on 'All Certification Types'
      page.should have_content 'All Certification Types'
      visit certification_type_path certification_type.id
      click_on 'Edit'
      click_on 'Create Certification Type'
      page.should have_content 'Create Certification Type'
    end

    it 'navigates All Certification Types' do
      visit certification_types_path
      page.should have_content 'All Certification Types'

      click_link 'Home'
      page.should have_content 'Welcome to CertoTrack'

      visit certification_types_path
      click_link 'Create Certification Type'
      page.should have_content 'Create Certification Type'

      visit certification_types_path
      click_link 'Search Certification Types'
      page.should have_content 'Search Certification Types'
    end

    it 'navigates Search Certification Types' do
      visit root_path

      click_link 'Search Certification Types'
      page.should have_content 'Search Certification Types'

      click_link 'Home'
      page.should have_content 'Welcome to CertoTrack'

      click_link 'Search Certification Types'
      click_link 'Create Certification Type'
      page.should have_content 'Create Certification Type'
    end
  end
end