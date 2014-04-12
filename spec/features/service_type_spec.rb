require 'spec_helper'

describe 'Service Types', slow: true, js: true do

  let(:customer) { create(:customer) }

  context 'show vehicle page' do
    context 'sorting' do
      before do
        login_as_vehicle_user(customer)
      end

      it 'should sort serviced vehicles by vehicle number' do
        oil_change = create(:service_type, name: 'Oil change', customer: customer)
        vehicle1 = create(:vehicle, vehicle_number: 'ABC123', customer: customer)
        vehicle2 = create(:vehicle, vehicle_number: 'XYZ111', customer: customer)
        vehicle3 = create(:vehicle, vehicle_number: 'LMNOP', customer: customer)
        create(:service, vehicle: vehicle1, service_type: oil_change)
        create(:service, vehicle: vehicle2, service_type: oil_change)
        create(:service, vehicle: vehicle3, service_type: oil_change)

        visit service_type_path(oil_change)

        within '[data-serviced-vehicles] table thead tr:nth-of-type(1)' do
          click_link 'Vehicle Number'
        end

        column_data_should_be_in_order('ABC123', 'LMNOP', 'XYZ111')

        within '[data-serviced-vehicles] table thead tr:nth-of-type(1)' do
          click_link 'Vehicle Number'
        end

        column_data_should_be_in_order('XYZ111', 'LMNOP', 'ABC123')
      end

      it 'should sort serviced vehicles by status' do
        oil_change = create(:service_type, name: 'Oil change', expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE, customer: customer)
        vehicle1 = create(:vehicle, customer: customer)
        vehicle2 = create(:vehicle, customer: customer)
        vehicle3 = create(:vehicle, customer: customer)
        create(:service, vehicle: vehicle1, service_type: oil_change, expiration_date: Date.yesterday)
        create(:service, vehicle: vehicle2, service_type: oil_change, expiration_date: Date.today+120.days)
        create(:service, vehicle: vehicle3, service_type: oil_change, expiration_date: Date.tomorrow)

        visit service_type_path(oil_change)

        within '[data-serviced-vehicles] table thead tr:nth-of-type(1)' do
          click_link 'Status'
        end

        column_data_should_be_in_order('Valid', 'Warning', 'Expired')

        within '[data-serviced-vehicles] table thead tr:nth-of-type(1)' do
          click_link 'Status'
        end

        column_data_should_be_in_order('Expired', 'Warning', 'Valid')
      end

      it 'should sort un-serviced vehicles by vehicle number' do
        oil_change = create(:service_type, name: 'Oil change', customer: customer)
        create(:vehicle, vehicle_number: 'ABC123', customer: customer)
        create(:vehicle, vehicle_number: 'XYZ111', customer: customer)
        create(:vehicle, vehicle_number: 'LMNOP', customer: customer)

        visit service_type_path(oil_change)

        within '[data-unserviced-vehicles] table thead tr:nth-of-type(1)' do
          click_link 'Vehicle Number'
        end

        column_data_should_be_in_order('ABC123', 'LMNOP', 'XYZ111')

        within '[data-unserviced-vehicles] table thead tr:nth-of-type(1)' do
          click_link 'Vehicle Number'
        end

        column_data_should_be_in_order('XYZ111', 'LMNOP', 'ABC123')
      end
    end
  end

  context 'when an vehicle user' do
    before do
      create(:service_type, name: 'Oil change', expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE, interval_mileage: 5000, customer: customer)
      pump_check = create(
        :service_type,
        name: 'Pump check',
        expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE,
        interval_mileage: 10000,
        interval_date: Interval::ONE_MONTH.text,
        customer: customer
      )
      create(:service_type, name: 'Tire rotation', expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE, interval_date: Interval::ONE_YEAR.text, customer: customer)
      golden = create(:location, name: 'Golden', customer: customer)
      unserviced_vehicle = create(:vehicle, vehicle_number: '34987', vin: '2B8GDM9AXKP042790', license_plate: '123-ABC',
                                  year: 1999, make: 'Dodge', vehicle_model: 'Dart', mileage: 20000, location: golden, customer: customer)
      serviced_vehicle = create(:vehicle, vehicle_number: '1111', vin: 'ABCGDM9AXK6D9H790', license_plate: '255-GLL',
                                year: 2009, make: 'Ford', vehicle_model: 'Edge', mileage: 60000, location: golden, customer: customer)
      create(
        :service,
        vehicle: serviced_vehicle,
        last_service_date: Date.new(2014, 1, 1),
        last_service_mileage: 1000,
        expiration_date: Date.new(2013, 1, 1),
        expiration_mileage: 50000,
        service_type: pump_check,
        customer: customer
      )

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

    it 'should show service type and serviced vehicles' do
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

      page.should have_content 'Serviced Vehicles'
      within '[data-serviced-vehicles] table thead tr' do
        page.should have_content 'Vehicle Number'
        page.should have_content 'VIN'
        page.should have_content 'License Plate'
        page.should have_content 'Year'
        page.should have_content 'Make'
        page.should have_content 'Model'
        page.should have_content 'Mileage'
        page.should have_content 'Location'
        page.should have_content 'Service Due Date'
        page.should have_content 'Service Due Mileage'
        page.should have_content 'Last Service Date'
        page.should have_content 'Last Service Mileage'
        page.should have_content 'Status'
        page.should have_content 'Service'
      end

      page.all('[data-serviced-vehicles] table tbody tr').count.should == 1

      within '[data-serviced-vehicles] table tbody tr:nth-of-type(1)' do
        page.should have_link '1111'
        page.should have_link 'ABCGDM9AXK6D9H790'
        page.should have_content '255-GLL'
        page.should have_content '2009'
        page.should have_content 'Ford'
        page.should have_content 'Edge'
        page.should have_content '1,000'
        page.should have_content 'Golden'
        page.should have_content '01/01/2014'
        page.should have_content '60,000'
        page.should have_content '01/01/2013'
        page.should have_content '60,000'
        page.should have_content 'Expired'
        page.should have_link 'Edit'
      end

      page.should have_content 'Non-Serviced Vehicles'

      within '[data-unserviced-vehicles] table thead tr' do
        page.should have_content 'Vehicle Number'
        page.should have_content 'VIN'
        page.should have_content 'License Plate'
        page.should have_content 'Year'
        page.should have_content 'Make'
        page.should have_content 'Model'
        page.should have_content 'Mileage'
        page.should have_content 'Location'
      end

      page.all('[data-unserviced-vehicles] table tbody tr').count.should == 1

      within '[data-unserviced-vehicles] table tbody tr:nth-of-type(1)' do
        page.should have_link '34987'
        page.should have_link '2B8GDM9AXKP042790'
        page.should have_content '123-ABC'
        page.should have_content '1999'
        page.should have_content 'Dodge'
        page.should have_content 'Dart'
        page.should have_content '20,000'
        page.should have_content 'Golden'
        page.should have_link 'Service'
      end

      within '[data-serviced-vehicles] table tbody tr:nth-of-type(1)' do
        click_link 'Edit'
      end

      page.should have_content 'Show Service'
      page.should have_content 'Pump check'
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

      within '[data-action-links]' do
        click_link 'Edit'
      end

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
      alert.text.should eq('Are you sure you want to delete this service type?')
      alert.dismiss

      page.should have_content 'Show Service Type'

      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this service type?')
      alert.accept

      page.should have_content 'All Service Types'
      page.should have_content 'Service Type was successfully deleted.'
    end

    it 'should not allow deletion if services exist' do
      service_type = create(:service_type, customer: customer, name: 'Manicure')
      create(:service, service_type: service_type, customer: service_type.customer)

      visit service_type_path service_type.id

      page.should have_content 'Show Service Type'
      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this service type?')
      alert.accept

      page.should have_content 'Show Service Type'
      page.should have_content 'This Service Type is assigned to existing Vehicle(s). You must remove the vehicle assignment(s) before removing it.'
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

      within '[data-unserviced-vehicles] table thead tr' do
        page.should have_content 'Vehicle Number'
        page.should have_content 'VIN'
        page.should have_content 'License Plate'
        page.should have_content 'Year'
        page.should have_content 'Make'
        page.should have_content 'Model'
        page.should have_content 'Mileage'
        page.should have_content 'Location'
      end

      page.all('[data-unserviced-vehicles] table tbody tr').count.should == 1

      within '[data-unserviced-vehicles] table tbody tr:nth-of-type(1)' do
        page.should have_content 'Dodge'
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

      within '[data-unserviced-vehicles] table thead tr' do
        page.should have_content 'Vehicle Number'
        page.should have_content 'VIN'
        page.should have_content 'License Plate'
        page.should have_content 'Year'
        page.should have_content 'Make'
        page.should have_content 'Model'
        page.should have_content 'Mileage'
        page.should have_content 'Location'
      end

      page.all('[data-unserviced-vehicles] table tbody tr').count.should == 1

      within '[data-unserviced-vehicles] table tbody tr:nth-of-type(1)' do
        page.should have_content 'Buick'
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
      no_date_interval = create(:service_type, interval_date: nil, customer: customer)
      zeta = create(:service_type, interval_date: Interval::FIVE_YEARS.text, customer: customer)
      beta = create(:service_type, interval_date: Interval::ONE_YEAR.text, customer: customer)
      alpha = create(:service_type, interval_date: Interval::ONE_MONTH.text, customer: customer)

      visit '/'
      click_link 'All Service Types'

      # Ascending sort
      click_link 'Interval Date'
      column_data_should_be_in_order('1 month', 'Annually', '5 years', '')

      # Descending sort
      click_link 'Interval Date'
      column_data_should_be_in_order('', '5 years', 'Annually', '1 month')
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