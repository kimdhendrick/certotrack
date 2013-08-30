require 'spec_helper'

describe 'Navigation', js: true do
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

      click_and_test_link_with_title 'All Equipment'

      visit root_path
      click_and_test_link_with_title 'Create Equipment'
    end

    it 'navigates All Equipment' do
      visit equipment_index_path
      page.should have_content 'All Equipment'

      page.should have_link 'Home'
      page.should have_link 'Create Equipment'
      page.should have_link 'Search Equipment'

      click_and_test_home_link

      visit equipment_index_path
      click_and_test_link_with_title 'Create Equipment'

      visit equipment_index_path
      click_and_test_link_with_title 'Search Equipment'
    end

    it 'navigates Expired Equipment List' do
      visit expired_equipment_path
      page.should have_content 'Expired Equipment List'

      page.should have_link 'Home'
      page.should have_link 'Create Equipment'
      page.should have_link 'Search Equipment'

      click_and_test_home_link

      visit expired_equipment_path
      click_and_test_link_with_title 'Create Equipment'

      visit expired_equipment_path
      click_and_test_link_with_title 'Search Equipment'
    end

    it 'navigates Expiring Equipment List' do
      visit expiring_equipment_path
      page.should have_content 'Expiring Equipment List'

      page.should have_link 'Home'
      page.should have_link 'Create Equipment'
      page.should have_link 'Search Equipment'

      click_and_test_home_link

      visit expiring_equipment_path
      click_and_test_link_with_title 'Create Equipment'

      visit expiring_equipment_path
      click_and_test_link_with_title 'Search Equipment'
    end

    it 'navigates Non-Inspectable Equipment List' do
      visit noninspectable_equipment_path
      page.should have_content 'Non-Inspectable Equipment List'

      page.should have_link 'Home'
      page.should have_link 'Create Equipment'
      page.should have_link 'Search Equipment'

      click_and_test_home_link

      visit noninspectable_equipment_path
      click_and_test_link_with_title 'Create Equipment'

      visit noninspectable_equipment_path
      click_and_test_link_with_title 'Search Equipment'
    end

    it 'navigates Create Equipment' do
      visit new_equipment_path
      page.should have_content 'Create Equipment'
      click_and_test_home_link
      visit new_equipment_path
      click_and_test_link_with_title 'Search Equipment'
    end

    it 'navigates Show Equipment' do
      equipment = create_equipment(customer: @customer)
      visit equipment_path equipment.id
      page.should have_content 'Show Equipment'

      page.should have_link 'Home'
      page.should have_link 'All Equipment'
      page.should have_link 'Search Equipment'
      page.should have_link 'Create Equipment'

      page.should have_link 'Edit'
      page.should have_link 'Delete'

      click_and_test_home_link

      visit equipment_path equipment.id
      click_and_test_link_with_title 'All Equipment'

      visit equipment_path equipment.id
      click_and_test_link_with_title 'Search Equipment'

      visit equipment_path equipment.id
      click_and_test_link_with_title 'Create Equipment'

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

      page.should have_content 'Edit Equipment'

      page.should have_link 'Home'
      page.should have_link 'All Equipment'
      page.should have_link 'Create Equipment'

      page.should have_link 'Delete'

      click_and_test_home_link
      visit equipment_path equipment.id
      click_on 'Edit'

      click_and_test_link_with_title 'All Equipment'
      visit equipment_path equipment.id
      click_on 'Edit'

      click_and_test_link_with_title 'Create Equipment'

      visit equipment_path equipment.id
      click_on 'Edit'
      click_link 'Delete'
      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete?')
      alert.dismiss
    end

    it 'navigates Search Equipment' do
      visit root_path

      within '[data-equipment-search-form]' do
        click_on 'Search'
      end

      page.should have_content 'Search Equipment'

      page.should have_link 'Home'
      page.should have_link 'Create Equipment'

      click_and_test_home_link
      within '[data-equipment-search-form]' do
        click_on 'Search'
      end

      click_and_test_link_with_title 'Create Equipment'
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
      page.should have_link 'Create Employee'


      click_and_test_link_with_title 'Create Certification Type'

      visit root_path
      click_and_test_link_with_title 'All Certification Types'

      visit root_path
      click_and_test_link_with_title 'Create Employee'
    end

    it 'navigates Create Certification Type' do
      visit new_certification_type_path
      page.should have_content 'Create Certification Type'

      click_and_test_home_link
      visit new_certification_type_path
      click_and_test_link_with_title 'Search Certification Types'
    end

    it 'navigates Show Certification Type' do
      certification_type = create_certification_type(customer: @customer)
      visit certification_type_path certification_type.id
      page.should have_content 'Show Certification Type'

      page.should have_link 'Home'
      page.should have_link 'All Certification Types'
      page.should have_link 'Search Certification Types'
      page.should have_link 'Create Certification Type'

      page.should have_link 'Edit'
      page.should have_link 'Delete'

      click_and_test_home_link

      visit certification_type_path certification_type.id
      click_and_test_link_with_title 'All Certification Types'

      visit certification_type_path certification_type.id
      click_and_test_link_with_title 'Search Certification Types'

      visit certification_type_path certification_type.id
      click_and_test_link_with_title 'Create Certification Type'

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

      page.should have_link 'Delete'

      click_and_test_home_link
      visit certification_type_path certification_type.id
      click_on 'Edit'

      click_and_test_link_with_title 'All Certification Types'
      visit certification_type_path certification_type.id
      click_on 'Edit'

      click_and_test_link_with_title 'Create Certification Type'

      visit certification_type_path certification_type.id
      click_on 'Edit'
      click_link 'Delete'
      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete?')
      alert.dismiss
    end

    it 'navigates All Certification Types' do
      visit certification_types_path
      page.should have_content 'All Certification Types'

      page.should have_link 'Home'
      page.should have_link 'Create Certification Type'
      page.should have_link 'Search Certification Types'

      click_and_test_home_link

      visit certification_types_path
      click_and_test_link_with_title 'Create Certification Type'

      visit certification_types_path
      click_and_test_link_with_title 'Search Certification Types'
    end

    it 'navigates Search Certification Types' do
      visit search_certification_types_path

      page.should have_content 'Search Certification Types'

      page.should have_link 'Home'
      page.should have_link 'Create Certification Type'

      click_and_test_home_link

      visit search_certification_types_path
      click_and_test_link_with_title 'Create Certification Type'
    end
  end

  describe 'Employee Links' do
    before do
      login_as_certification_user
    end

    it 'navigates Create Employee' do
      visit new_employee_path
      page.should have_content 'Create Employee'
      page.should have_link 'Home'
      page.should have_link 'All Employees'

      click_and_test_home_link
      click_and_test_link_with_title 'All Employees'
    end

    it 'navigates All Employees' do
      visit employees_path
      page.should have_content 'All Employees'

      page.should have_link 'Home'
      page.should have_link 'Create Employee'

      click_and_test_home_link

      visit employees_path
      click_and_test_link_with_title 'Create Employee'
    end

    it 'navigates Show Employee' do
      employee = create_employee(customer: @customer)
      visit employee_path employee.id
      page.should have_content 'Show Employee'

      page.should have_link 'Home'
      page.should have_link 'All Employees'
      page.should have_link 'Create Employee'

      page.should have_link 'Edit'
      page.should have_link 'Delete'

      click_and_test_home_link

      visit employee_path employee.id
      click_and_test_link_with_title 'All Employees'

      visit employee_path employee.id
      click_and_test_link_with_title 'Create Employee'

      #visit employee_path employee.id
      #click_link 'Edit'
      #page.should have_content 'Edit Employee'

      visit employee_path employee.id
      click_link 'Delete'
      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete?')
      alert.dismiss
    end
  end

  def click_and_test_home_link
    click_link 'Home'
    page.should have_content 'Welcome to CertoTrack'
  end

  def click_and_test_link_with_title(link_title)
    click_link link_title
    page.should have_content link_title
  end
end