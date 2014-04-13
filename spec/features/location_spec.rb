require 'spec_helper'

describe 'Locations', slow: true do

  let(:customer) { create(:customer) }

  context 'when an equipment user' do
    before do
      login_as_equipment_user(customer)
      create(:location, name: 'Hawaii', customer: customer)
      create(:location, name: 'Alaska', customer: customer)
    end

    it 'should list all locations' do
      visit root_path

      page.should have_link 'All Locations'
      click_on 'All Locations'

      page.should have_content 'All Locations'

      within 'table thead tr' do
        page.should have_content 'Location'
      end

      within 'table tbody tr:nth-of-type(1)' do
        page.should have_link 'Alaska'
      end

      within 'table tbody tr:nth-of-type(2)' do
        page.should have_link 'Hawaii'
      end
    end

    it 'should show and edit a location' do
      visit root_path
      click_on 'All Locations'
      click_on 'Alaska'
      page.should have_content 'Show Location'
      page.should have_content 'Alaska'

      page.should have_link 'Edit'

      click_on 'Edit'

      page.should have_content 'Edit Location'
      page.should have_link 'Home'
      page.should have_link 'All Locations'
      page.should have_link 'Create Location'

      fill_in 'Location', with: 'China'
      page.should_not have_content 'Customer'

      click_on 'Update'

      page.should have_content 'Show Location'
      page.should have_content "Location 'China' was successfully updated."
      page.should have_content 'China'
      page.should_not have_content 'Customer'
    end

    it 'should be able to create a new location' do
      visit root_path

      page.should have_link 'All Locations'
      click_on 'All Locations'

      page.should have_link 'Create Location'

      click_on 'Create Location'

      page.should have_content 'Create Location'
      page.should have_link 'Home'
      page.should have_link 'All Locations'

      fill_in 'Location', with: 'Siberia'
      page.should_not have_content 'Customer'

      click_on 'Create'

      page.should have_content 'Show Location'
      page.should have_content "Location 'Siberia' was successfully created"
      page.should have_content 'Siberia'
      page.should_not have_content 'Customer'
    end

    it 'should be able to delete a location', js: true do
      visit root_path
      click_on 'All Locations'
      click_on 'Alaska'
      click_on 'Delete'
      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this location?')
      alert.dismiss

      click_on 'Delete'
      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this location?')
      alert.accept

      page.should have_content "Location 'Alaska' was successfully deleted"
      page.should have_content 'All Location'
    end

    it 'should not delete location with equipment assigned', js: true do
      location = create(:location, name: 'San Antonio', customer: customer)

      create(:equipment, location: location)

      visit '/'
      click_link 'All Locations'
      click_link 'San Antonio'

      page.should have_content 'Show Location'
      click_on 'Delete'

      page.driver.browser.switch_to.alert.accept

      page.should have_content 'Show Location'
      page.should have_content 'Location has equipment assigned, you must reassign them before deleting the location.'
    end

    it 'should not delete location with employee assigned', js: true do
      location = create(:location, name: 'San Antonio', customer: customer)

      create(:employee, location: location)

      visit '/'
      click_link 'All Locations'
      click_link 'San Antonio'

      page.should have_content 'Show Location'
      click_on 'Delete'

      page.driver.browser.switch_to.alert.accept

      page.should have_content 'Show Location'
      page.should have_content 'Location has employees assigned, you must reassign them before deleting the location.'
    end

    it 'should not delete location with vehicle assigned', js: true do
      location = create(:location, name: 'San Antonio', customer: customer)

      create(:vehicle, location: location)

      visit '/'
      click_link 'All Locations'
      click_link 'San Antonio'

      page.should have_content 'Show Location'
      click_on 'Delete'

      page.driver.browser.switch_to.alert.accept

      page.should have_content 'Show Location'
      page.should have_content 'Location has vehicles assigned, you must reassign them before deleting the location.'
    end
  end

  context 'when an admin user' do
    let(:customer1) { create(:customer, name: 'Customer1') }
    let(:customer2) { create(:customer, name: 'Husky League') }

    before do
      login_as_admin
      create(:location, name: 'Texas', customer: customer1)
      create(:location, name: 'Florida', customer: customer2)
    end

    it 'should show all locations for all customers' do
      click_link 'All Locations'

      page.should have_content 'Customer'
      #page.should have_link 'Customer'

      page.should have_content 'Texas'
      page.should have_content 'Florida'
    end

    it 'should show and edit a location', js: true do
      visit root_path
      click_on 'All Locations'
      click_on 'Texas'
      page.should have_content 'Show Location'
      page.should have_content 'Texas'
      page.should have_content 'Customer1'

      page.should have_link 'Edit'

      click_on 'Edit'

      page.should have_content 'Edit Location'
      page.should have_link 'Home'
      page.should have_link 'All Locations'
      page.should have_link 'Create Location'

      page.should have_link 'Delete'
      click_on 'Delete'
      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this location?')
      alert.dismiss

      fill_in 'Location', with: 'China'
      select 'Husky League', from: 'Customer'

      click_on 'Update'

      page.should have_content 'Show Location'
      page.should have_content "Location 'China' was successfully updated."
      page.should have_content 'China'
      page.should have_content 'Husky League'
    end

    it 'should be able to create a new location for any customer' do
      visit root_path

      page.should have_link 'All Locations'
      click_on 'All Locations'

      page.should have_link 'Create Location'

      click_on 'Create Location'

      page.should have_content 'Create Location'
      page.should have_link 'Home'
      page.should have_link 'All Locations'

      fill_in 'Location', with: 'Siberia'
      select 'Husky League', from: 'Customer'

      click_on 'Create'

      page.should have_content 'Show Location'
      page.should have_content "Location 'Siberia' was successfully created"
      page.should have_content 'Siberia'
      page.should have_content 'Husky League'
    end

    it 'should be able to delete a location', js: true do
      visit root_path
      click_on 'All Locations'
      click_on 'Florida'
      click_on 'Delete'
      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this location?')
      alert.dismiss

      click_on 'Delete'
      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this location?')
      alert.accept

      page.should have_content "Location 'Florida' was successfully deleted"
      page.should have_content 'All Locations'
    end
  end

  context 'sorting' do
    it 'should sort by name' do
      login_as_equipment_user(customer)

      zeta = create(:location, name: 'zeta', customer: customer)
      beta = create(:location, name: 'beta', customer: customer)
      alpha = create(:location, name: 'alpha', customer: customer)

      visit '/'
      click_link 'All Locations'

      # Ascending sort
      click_link 'Location'
      column_data_should_be_in_order('alpha', 'beta', 'zeta')

      # Descending sort
      click_link 'Location'
      column_data_should_be_in_order('zeta', 'beta', 'alpha')
    end

    it 'should sort by customer when admin' do
      login_as_admin
      customer1 = create(:customer, name: 'zeta')
      customer2 = create(:customer, name: 'beta')
      customer3 = create(:customer, name: 'alpha')

      zeta = create(:location, customer: customer1)
      beta = create(:location, customer: customer2)
      alpha = create(:location, customer: customer3)

      visit '/'
      click_link 'All Locations'

      # Ascending sort
      click_link 'Customer'
      column_data_should_be_in_order('alpha', 'beta', 'zeta')

      # Descending sort
      click_link 'Customer'
      column_data_should_be_in_order('zeta', 'beta', 'alpha')
    end
  end

  context 'pagination' do
    before do
      login_as_equipment_user(customer)
    end

    it 'should paginate' do
      55.times do
        create(:location, customer: customer)
      end

      visit '/'
      click_link 'All Locations'

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