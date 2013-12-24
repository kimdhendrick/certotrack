require 'spec_helper'

describe 'Service Types', slow: true, js: true do

  let(:customer) { create(:customer) }

  context 'when an vehicle user' do
    before do
      create(:service_type, name: 'Oil change', expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE, interval_mileage: 5000, customer: customer)
      create(:service_type, name: 'Pump check', expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE, interval_mileage: 10000, interval_date: Interval::ONE_MONTH.text, customer: customer)
      create(:service_type, name: 'Tire rotation', expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE, interval_date: Interval::ONE_YEAR.text, customer: customer)
      golden = create(:location, name: 'Golden', customer: customer)
      create(:vehicle, vehicle_number: '34987', vin: '2B8GDM9AXKP042790', license_plate: '123-ABC',
             year: 1999, make: 'Dodge', vehicle_model: 'Dart', mileage: 20000, location: golden, customer: customer)

      login_as_vehicle_user(customer)
    end

    it 'should list all service types' do
      visit root_path

      page.should have_link 'All Service Types'
      click_on 'All Service Types'

      page.should have_content 'All Service Types'

      within 'table thead tr' do
        page.should have_link 'Name'
        page.should have_link 'Expiration Type'
        page.should have_link 'Interval Date'
        page.should have_link 'Interval Mileage'
      end

      within 'table tbody tr:nth-of-type(1)' do
        page.should have_link 'Oil change'
        page.should have_content 'By Mileage'
        page.should have_content '5,000'
      end

      within 'table tbody tr:nth-of-type(2)' do
        page.should have_link 'Pump check'
        page.should have_content 'By Date and Mileage'
        page.should have_content '1 month'
        page.should have_content '10,000'
      end
    end

    it 'should show service type' do
      visit root_path

      click_on 'All Service Types'

      click_link 'Pump check'

      page.should have_content 'Show Service Type'

      page.should have_content 'Name'
      page.should have_content 'Expiration Type'
      page.should have_content 'Interval Date'
      page.should have_content 'Interval Mileage'

      page.should have_content 'Pump check'
      page.should have_content 'By Date and Mileage'
      page.should have_content '10,000'

      page.should have_content 'Non-Serviced Vehicles'

      within 'table thead tr' do
        page.should have_content 'Vehicle Number'
        page.should have_content 'VIN'
        page.should have_content 'License Plate'
        page.should have_content 'Year'
        page.should have_content 'Make'
        page.should have_content 'Model'
        page.should have_content 'Mileage'
        page.should have_content 'Location'
      end

      page.all('table tr').count.should == 2

      within 'table tbody tr:nth-of-type(1)' do
        page.should have_link '34987'
        page.should have_link '2B8GDM9AXKP042790'
        page.should have_content '123-ABC'
        page.should have_content '1999'
        page.should have_content 'Dodge'
        page.should have_content 'Dart'
        page.should have_content '20,000'
        page.should have_content 'Golden'
        #TODO
        #page.should have_link 'Service'
        page.should have_content 'Service'
      end
    end

    it 'should create new service types' do
      visit '/'
      click_link 'Create Service Type'

      page.should have_content 'Create Service Type'
      page.should have_link 'Home'
      page.should have_link 'All Service Types'

      page.should have_content 'Name'
      page.should have_content 'Expiration Type'
      page.should have_content 'Interval Date'
      page.should have_content 'Interval Mileage'

      fill_in 'Name', with: 'Happiness Check'
      select 'By Date and Mileage', from: 'Expiration Type'
      select 'Annually', from: 'Interval Date'
      select '15000', from: 'Interval Mileage'

      click_on 'Create'

      page.should have_content 'Show Service Type'
      page.should have_content 'Service Type was successfully created.'

      page.should have_content 'Name Happiness Check'
      page.should have_content 'Expiration Type By Date and Mileage'
      page.should have_content 'Interval Date Annually'
      page.should have_content 'Interval Mileage 15,000'
    end

    it 'should update service types' do
      visit root_path

      click_on 'All Service Types'

      click_link 'Pump check'

      page.should have_content 'Show Service Type'

      click_link 'Edit'

      fill_in 'Name', with: 'Cheery Check'
      select 'By Date', from: 'Expiration Type'
      select '6 months', from: 'Interval Date'

      click_on 'Update'

      page.should have_content 'Show Service Type'
      page.should have_content 'Service Type was successfully updated.'

      page.should have_content 'Cheery Check'
      page.should have_content '6 months'
      page.should have_content 'By Date'
    end

    it 'should delete existing service_type' do
      service_type = create(:service_type, customer: customer, name: 'Manicure')

      visit service_type_path service_type.id

      page.should have_content 'Show Service Type'
      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete?')
      alert.dismiss

      page.should have_content 'Show Service Type'

      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete?')
      alert.accept

      page.should have_content 'All Service Types'
      page.should have_content 'Service Type was successfully deleted.'
    end

    xit 'should not allow deletion if services exist' do
      service_type = create(:service_type, customer: customer, name: 'Manicure')
      create(:service, service_type: service_type, customer: service_type.customer)

      visit service_type_path service_type.id

      page.should have_content 'Show Service Type'
      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete?')
      alert.accept

      page.should have_content 'Show Service Type'
      page.should have_content 'This Service Type is assigned to existing Vehicle(s).  You must remove the service from the vehicle(s) before removing it.'
    end
  end

  context 'when an admin user' do
    let(:customer1) { create(:customer, name: 'Customer1') }
    let(:customer2) { create(:customer, name: 'Customer2') }

    before do
      create(:service_type, name: 'Oil change', expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE, interval_mileage: 5000, customer: customer1)
      create(:service_type, name: 'Pump check', expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE, interval_mileage: 10000, interval_date: Interval::ONE_MONTH.text, customer: customer2)

      boulder = create(:location, name: 'Boulder', customer: customer1)
      create(:vehicle, vehicle_number: '77777', vin: '3C8GDM9AXKP042701', license_plate: '789-XYZ',
             year: 1970, make: 'Buick', vehicle_model: 'Riviera', mileage: 56000, location: boulder, customer: customer1)

      golden = create(:location, name: 'Golden', customer: customer2)
      create(:vehicle, vehicle_number: '34987', vin: '2B8GDM9AXKP042790', license_plate: '123-ABC',
             year: 1999, make: 'Dodge', vehicle_model: 'Dart', mileage: 20000, location: golden, customer: customer2)

      login_as_admin
    end

    it 'should list all service types for all customers' do
      click_link 'All Service Types'

      page.should have_content 'Oil change'
      page.should have_content 'Pump check'
    end

    it 'should show service type' do
      visit root_path

      click_on 'All Service Types'

      click_link 'Pump check'

      page.should have_content 'Show Service Type'

      page.should have_content 'Name'
      page.should have_content 'Expiration Type'
      page.should have_content 'Interval Date'
      page.should have_content 'Interval Mileage'

      page.should have_content 'Pump check'
      page.should have_content 'By Date and Mileage'
      page.should have_content '10,000'
      page.should have_content '1 month'

      page.should have_content 'Non-Serviced Vehicles'

      within 'table thead tr' do
        page.should have_content 'Vehicle Number'
        page.should have_content 'VIN'
        page.should have_content 'License Plate'
        page.should have_content 'Year'
        page.should have_content 'Make'
        page.should have_content 'Model'
        page.should have_content 'Mileage'
        page.should have_content 'Location'
      end

      page.all('table tr').count.should == 3

      within 'table tbody tr:nth-of-type(1)' do
        page.should have_link '34987'
        page.should have_link '2B8GDM9AXKP042790'
        page.should have_content '123-ABC'
        page.should have_content '1999'
        page.should have_content 'Dodge'
        page.should have_content 'Dart'
        page.should have_content '20,000'
        page.should have_content 'Golden'
        #TODO
        #page.should have_link 'Service'
        page.should have_content 'Service'
      end

      visit root_path

      click_on 'All Service Types'

      click_link 'Oil change'

      page.should have_content 'Show Service Type'

      page.should have_content 'Name'
      page.should have_content 'Expiration Type'
      page.should_not have_content 'Interval Date'
      page.should have_content 'Interval Mileage'

      page.should have_content 'Oil change'
      page.should have_content 'By Mileage'
      page.should have_content '5,000'

      page.should have_content 'Non-Serviced Vehicles'

      within 'table thead tr' do
        page.should have_content 'Vehicle Number'
        page.should have_content 'VIN'
        page.should have_content 'License Plate'
        page.should have_content 'Year'
        page.should have_content 'Make'
        page.should have_content 'Model'
        page.should have_content 'Mileage'
        page.should have_content 'Location'
      end

      page.all('table tr').count.should == 3

      within 'table tbody tr:nth-of-type(2)' do
        page.should have_link '77777'
        page.should have_link '3C8GDM9AXKP042701'
        page.should have_content '789-XYZ'
        page.should have_content '1970'
        page.should have_content 'Buick'
        page.should have_content 'Riviera'
        page.should have_content '56,000'
        page.should have_content 'Boulder'
        #TODO
        #page.should have_link 'Service'
        page.should have_content 'Service'
      end
    end
  end

  context 'sorting' do
    before do
      login_as_vehicle_user(customer)
    end

    it 'should sort by service type' do
      zeta = create(:service_type, name: 'zeta', customer: customer)
      beta = create(:service_type, name: 'beta', customer: customer)
      alpha = create(:service_type, name: 'alpha', customer: customer)

      visit '/'
      click_link 'All Service Types'

      # Ascending sort
      click_link 'Name'
      column_data_should_be_in_order('alpha', 'beta', 'zeta')

      # Descending sort
      click_link 'Name'
      column_data_should_be_in_order('zeta', 'beta', 'alpha')
    end

    it 'should sort by expiration_type' do
      zeta = create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE, customer: customer)
      beta = create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE, customer: customer)
      alpha = create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE, customer: customer)

      visit '/'
      click_link 'All Service Types'

      # Ascending sort
      click_link 'Expiration Type'
      column_data_should_be_in_order('By Date', 'By Date and Mileage', 'By Mileage')

      # Descending sort
      click_link 'Expiration Type'
      column_data_should_be_in_order('By Mileage', 'By Date and Mileage', 'By Date')
    end

    it 'should sort by interval date' do
      zeta = create(:service_type, interval_date: Interval::FIVE_YEARS.text, customer: customer)
      beta = create(:service_type, interval_date: Interval::ONE_YEAR.text, customer: customer)
      alpha = create(:service_type, interval_date: Interval::ONE_MONTH.text, customer: customer)

      visit '/'
      click_link 'All Service Types'

      # Ascending sort
      click_link 'Interval Date'
      column_data_should_be_in_order('1 month', 'Annually', '5 years')

      # Descending sort
      click_link 'Interval Date'
      column_data_should_be_in_order('5 years', 'Annually', '1 month')
    end

    it 'should sort by interval mileage' do
      zeta = create(:service_type, interval_mileage: 10000, customer: customer)
      beta = create(:service_type, interval_mileage: 5000, customer: customer)
      alpha = create(:service_type, interval_mileage: 3000, customer: customer)

      visit '/'
      click_link 'All Service Types'

      # Ascending sort
      click_link 'Interval Mileage'
      column_data_should_be_in_order('3,000', '5,000', '10,000')

      # Descending sort
      click_link 'Interval Mileage'
      column_data_should_be_in_order('10,000', '5,000', '3,000')
    end
  end

  context 'pagination' do
    before do
      login_as_vehicle_user(customer)
    end

    it 'should paginate' do
      55.times do
        create(:service_type, customer: customer)
      end

      visit '/'
      click_link 'All Service Types'

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