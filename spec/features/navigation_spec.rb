require 'spec_helper'

describe 'Navigation', slow: true do
  let(:customer) { create(:customer) }

  describe 'Equipment Links' do
    before do
      login_as_equipment_user(customer)
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

    it 'navigates Show Equipment', js: true do
      equipment = create(:equipment, customer: customer)
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

    it 'navigates Edit Equipment', js: true do
      equipment = create(:equipment, customer: customer)
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
      login_as_certification_user(customer)
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

    it 'navigates All Employee Certifications' do
      visit certifications_path
      page.should have_link 'Home'
      page.should have_link 'Create Certification'
    end

    it 'navigates Create Certification Type' do
      visit new_certification_type_path
      page.should have_content 'Create Certification Type'

      click_and_test_home_link
      visit new_certification_type_path
      click_and_test_link_with_title 'Search Certification Types'
    end

    it 'navigates Show Certification Type', js: true do
      certification_type = create(:certification_type, customer: customer)
      visit certification_type_path certification_type.id
      page.should have_content 'Show Certification Type'

      page.should have_link 'Home'
      page.should have_link 'Search Certification Types'
      page.should have_link 'Create Certification Type'

      page.should have_link 'Edit'
      page.should have_link 'Delete'

      click_and_test_home_link

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

    it 'navigates Edit Certification Type', js: true do
      certification_type = create(:certification_type, customer: customer)
      visit certification_type_path certification_type.id

      click_on 'Edit'

      page.should have_content 'Edit Certification Type'

      page.should have_link 'Home'
      page.should have_link 'Search Certification Types'
      page.should have_link 'Create Certification Type'

      page.should have_link 'Delete'

      click_and_test_home_link
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

    it 'navigates Certification', js: true do
      certification = create(:certification,
                             employee: create(:employee, first_name: 'First', last_name: 'Last', customer: customer),
                             certification_type: create(:certification_type, customer: customer)
      )
      visit certification_path certification.id
      click_on 'Create Certification'

      page.should have_link 'Home'
      page.should have_link 'Search Certifications'
      page.should have_link 'Create Certification Type'
      page.should have_link 'Create Employee'

      visit certification_path certification.id
      click_on 'Certification History'

      page.should have_link 'Home'
      page.should have_link 'Search Certifications'

      visit certification_path certification.id

      click_on 'Recertify'

      page.should have_link 'Home'
      page.should have_link 'Search Certifications'
      page.should have_link 'Create Certification'

      visit certification_path certification.id
      click_on 'Edit'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to edit instead of recertify?')
      alert.accept

      page.should have_content 'Edit Certification'

      page.should have_link 'Home'
      page.should have_link 'Search Certifications'
      page.should have_link 'Create Certification'

      page.should have_link 'Delete'

      click_and_test_home_link
      visit certification_path certification.id
      click_on 'Edit'
      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to edit instead of recertify?')
      alert.accept

      click_on 'First Last'
      page.should have_content 'Show Employee'
      visit certification_path certification.id
      click_on 'Edit'
      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to edit instead of recertify?')
      alert.accept

      click_and_test_link_with_title 'Create Certification Type'

      visit certification_path certification.id
      click_on 'Edit'
      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to edit instead of recertify?')
      alert.accept

      click_link 'Delete'
      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this certification?')
      alert.dismiss
    end
  end

  describe 'Employee Links' do
    before do
      login_as_certification_user(customer)
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

    it 'navigates Show Employee', js: true do
      employee = create(:employee, customer: customer)
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

    it 'navigates Edit Employee', js: true do
      employee = create(:employee, customer: customer)
      visit employee_path employee.id

      click_on 'Edit'

      page.should have_content 'Edit Employee'

      page.should have_link 'Home'
      page.should have_link 'All Employees'
      page.should have_link 'Create Employee'

      page.should have_link 'Delete'

      click_and_test_home_link
      visit employee_path employee.id
      click_on 'Edit'

      click_and_test_link_with_title 'All Employees'
      visit employee_path employee.id
      click_on 'Edit'

      click_and_test_link_with_title 'Create Employee'

      visit employee_path employee.id
      click_on 'Edit'
      click_link 'Delete'
      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete?')
      alert.dismiss
    end
  end

  describe 'Administration Links' do
    it 'when certification user' do
      login_as_certification_user(customer)
      visit '/'

      page.should have_link 'Deactivated Employees'

      click_on 'Deactivated Employees'

      page.should have_content 'Deactivated Employee List'

      page.should have_link 'Home'
      click_and_test_home_link
    end
  end

  describe 'Recertification Links' do
    let(:certification) { create(:certification, customer: customer) }
    subject { page }

    before do
      login_as_certification_user(customer)
      visit new_certification_recertification_path(certification)
    end

    it 'should have link to home' do
      page.should have_link 'Home'
      click_and_test_link_with_title 'Home'
    end

    it 'should have link to create certification' do
      page.should have_link 'Create Certification'
      click_and_test_link_with_title 'Create Certification'
    end
  end

  describe 'Location Links' do
    before do
      login_as_certification_user(customer)
      create(:location, name: 'My Location', customer: customer)
    end

    it 'should have all the right stuff' do
      visit root_path
      click_on 'All Locations'
      page.should have_content 'All Locations'

      click_and_test_home_link
      click_on 'All Locations'
      click_and_test_link_with_title 'Create Location'
      visit root_path
      click_on 'All Locations'

      click_on 'My Location'
      page.should have_content 'Show Location'
      click_and_test_home_link
      click_on 'All Locations'
      click_on 'My Location'

      click_and_test_link_with_title 'All Locations'
      visit root_path
      click_on 'All Locations'
      click_on 'My Location'

      click_and_test_link_with_title 'Create Location'
      visit root_path
      click_on 'All Locations'
      click_on 'My Location'

      click_on 'Edit'
      page.should have_content 'Edit Location'
      click_and_test_home_link
      click_and_test_link_with_title 'All Locations'
      click_and_test_link_with_title 'Create Location'
    end
  end

  describe 'Vehicle Links' do
    before do
      login_as_vehicle_user(customer)
      create(:vehicle, vehicle_number: 'My Vehicle', customer: customer)
    end

    it 'should have all the right stuff' do
      visit root_path
      click_on 'All Vehicles'
      page.should have_content 'All Vehicles'

      click_and_test_home_link
      click_on 'All Vehicles'
      click_and_test_link_with_title 'Create Vehicle'
      visit root_path
      click_on 'All Vehicles'

      click_on 'My Vehicle'
      page.should have_content 'Show Vehicle'
      click_and_test_home_link
      click_on 'All Vehicles'
      click_on 'My Vehicle'

      click_and_test_link_with_title 'Search Vehicles'
      visit root_path
      click_on 'All Vehicles'
      click_on 'My Vehicle'

      click_and_test_link_with_title 'Create Vehicle'
      visit root_path
      click_on 'All Vehicles'
      click_on 'My Vehicle'

      click_on 'Edit'
      page.should have_content 'Edit Vehicle'
      click_and_test_home_link

      visit root_path
      click_on 'All Vehicles'
      click_on 'My Vehicle'
      click_on 'Edit'
      click_and_test_link_with_title 'Search Vehicles'

      visit root_path
      click_on 'All Vehicles'
      click_on 'My Vehicle'
      click_on 'Edit'
      click_and_test_link_with_title 'Create Vehicle'
      
      visit root_path
      within '[data-vehicle-search-form]' do
        click_on 'Search'
      end

      page.should have_content 'Search Vehicles'

      page.should have_link 'Home'
      page.should have_link 'Create Vehicle'

      click_and_test_home_link
      within '[data-vehicle-search-form]' do
        click_on 'Search'
      end

      click_and_test_link_with_title 'Create Vehicle'
    end
  end

  describe 'Service Links' do
    before do
      login_as_vehicle_user(customer)
      create(:service_type, name: 'Oil Change', customer: customer)
    end

    it 'should have all the right stuff' do
      visit root_path
      click_on 'All Service Types'
      page.should have_content 'All Service Types'

      click_and_test_home_link
      click_on 'All Service Types'
      click_and_test_link_with_title 'Create Service Type'
      visit root_path
      click_on 'All Service Types'

      click_on 'Oil Change'
      page.should have_content 'Show Service Type'
      click_and_test_home_link
      click_on 'All Service Types'
      click_on 'Oil Change'

      click_and_test_link_with_title 'Create Service Type'
      visit root_path
      click_on 'All Service Types'
      click_on 'Oil Change'
      click_and_test_link_with_title 'All Service Types'

      visit root_path
      click_on 'All Service Types'
      click_on 'Oil Change'
      click_on 'Edit'
      page.should have_content 'Edit Service Type'
      click_and_test_home_link

      visit root_path
      click_on 'All Service Types'
      click_on 'Oil Change'
      click_on 'Edit'
      click_and_test_link_with_title 'Create Service Type'

      visit root_path
      click_on 'All Service Types'
      click_on 'Oil Change'
      page.should have_content 'Show Service Type'
      click_on 'Edit'
      page.should have_content 'Edit Service Type'
      click_and_test_link_with_title 'All Vehicle Services'

      visit root_path
      click_on 'All Service Types'
      click_on 'Create Service'
      click_and_test_link_with_title 'Home'

      visit root_path
      click_on 'All Service Types'
      click_on 'Create Service'
      click_and_test_link_with_title 'All Service Types'
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