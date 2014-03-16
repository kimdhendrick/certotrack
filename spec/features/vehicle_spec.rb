require 'spec_helper'

describe 'Vehicles', slow: true do

  let(:customer) { create(:customer) }

  context 'when a vehicle user' do
    before do
      denver = create(:location, name: 'Denver', customer: customer)
      golden = create(:location, name: 'Golden', customer: customer)
      boulder = create(:location, name: 'Boulder', customer: customer)

      @vehicle1 = create(:vehicle, vehicle_number: '987345', vin: '1M8GDM9AXKP042788', license_plate: 'ABC-123',
                         year: 2013, make: 'Chevrolet', vehicle_model: 'Chevette', mileage: 10000, location: denver, customer: customer)

      create(:vehicle, vehicle_number: '34987', vin: '2B8GDM9AXKP042790', license_plate: '123-ABC',
             year: 1999, make: 'Dodge', vehicle_model: 'Dart', mileage: 20000, location: golden, customer: customer)

      create(:vehicle, vehicle_number: '77777', vin: '3C8GDM9AXKP042701', license_plate: '789-XYZ',
             year: 1970, make: 'Buick', vehicle_model: 'Riviera', mileage: 56000, location: boulder, customer: customer)

      login_as_vehicle_user(customer)
    end

    it 'should list all vehicles' do
      visit root_path

      page.should have_link 'All Vehicles'
      click_on 'All Vehicles'

      page.should have_content 'All Vehicles'

      within 'table thead tr' do
        page.should have_link 'Vehicle Number'
        page.should have_link 'VIN'
        page.should have_link 'License Plate'
        page.should have_link 'Year'
        page.should have_link 'Make'
        page.should have_link 'Model'
        page.should have_link 'Mileage'
        page.should have_link 'Location'
        page.should have_link 'Status'
      end

      within 'table tbody tr:nth-of-type(1)' do
        page.should have_link '34987'
        page.should have_link '2B8GDM9AXKP042790'
        page.should have_content '123-ABC'
        page.should have_content '1999'
        page.should have_content 'Dodge'
        page.should have_content 'Dart'
        page.should have_content '20,000'
        page.should have_content 'Golden'
        page.should have_content 'N/A'
      end

      within 'table tbody tr:nth-of-type(2)' do
        page.should have_link '77777'
        page.should have_link '3C8GDM9AXKP042701'
        page.should have_content '789-XYZ'
        page.should have_content '1970'
        page.should have_content 'Buick'
        page.should have_content 'Riviera'
        page.should have_content '56,000'
        page.should have_content 'Boulder'
        page.should have_content 'N/A'
      end

      within 'table tbody tr:nth-of-type(3)' do
        page.should have_link '987345'
        page.should have_link '1M8GDM9AXKP042788'
        page.should have_content 'ABC-123'
        page.should have_content '2013'
        page.should have_content 'Chevrolet'
        page.should have_content 'Chevette'
        page.should have_content '10,000'
        page.should have_content 'Denver'
        page.should have_content 'N/A'
      end
    end

    it 'should be able to create a new vehicle' do
      visit root_path

      page.should have_link 'All Vehicles'
      click_on 'All Vehicles'

      page.should have_link 'Create Vehicle'

      click_on 'Create Vehicle'

      page.should have_content 'Create Vehicle'
      page.should have_link 'Home'
      page.should have_link 'Search Vehicles'

      fill_in 'Vehicle Number', with: '3921-A'
      fill_in 'VIN', with: '98765432109876543'
      fill_in 'License Plate', with: 'CTIsCool'
      fill_in 'Year', with: '2013'
      fill_in 'Make', with: 'Audi'
      fill_in 'Model', with: 'A3'
      fill_in 'Mileage', with: '15'
      select 'Golden', from: 'vehicle_location_id'

      click_on 'Create'

      page.should have_content 'Show Vehicle'
      page.should have_content 'Vehicle was successfully created'
      page.should have_content '3921-A'
      page.should have_content '98765432109876543'
      page.should have_content 'CTIsCool'
      page.should have_content '2013'
      page.should have_content 'Audi'
      page.should have_content 'A3'
      page.should have_content '15'
      page.should have_content 'Golden'
    end

    it 'should show and edit a vehicle' do
      visit root_path
      click_on 'All Vehicles'
      click_on '1M8GDM9AXKP042788'

      page.should have_content 'Show Vehicle'

      page.should have_link 'Home'
      page.should have_link 'Search Vehicles'
      page.should have_link 'Create Vehicle'

      page.should have_content '1M8GDM9AXKP042788'
      page.should have_content '987345'
      page.should have_content 'ABC-123'
      page.should have_content '2013'
      page.should have_content 'Chevrolet'
      page.should have_content 'Chevette'
      page.should have_content '10,000'
      page.should have_content 'Denver'

      visit root_path
      click_on 'All Vehicles'
      click_on '987345'

      page.should have_content 'Show Vehicle'
      page.should have_content '1M8GDM9AXKP042788'
      page.should have_content '987345'
      page.should have_content 'ABC-123'
      page.should have_content '2013'
      page.should have_content 'Chevrolet'
      page.should have_content 'Chevette'
      page.should have_content '10,000'
      page.should have_content 'Denver'

      page.should have_link 'Edit'

      click_on 'Edit'

      page.should have_content 'Edit Vehicle'
      page.should have_link 'Home'
      page.should have_link 'Search Vehicles'
      page.should have_link 'Create Vehicle'
      page.should have_link 'Delete'

      fill_in 'Vehicle Number', with: '3921-A'
      fill_in 'VIN', with: '98765432109876543'
      fill_in 'License Plate', with: 'CTIsCool'
      fill_in 'Year', with: '2010'
      fill_in 'Make', with: 'Audi'
      fill_in 'Model', with: 'A3'
      fill_in 'Mileage', with: '15'
      select 'Golden', from: 'vehicle_location_id'

      click_on 'Update'

      page.should have_content 'Show Vehicle'
      page.should have_content 'Vehicle number 3921-A was successfully updated.'
      page.should have_content '3921-A'

      page.should have_content '3921-A'
      page.should have_content '98765432109876543'
      page.should have_content 'CTIsCool'
      page.should have_content '2010'
      page.should have_content 'Audi'
      page.should have_content 'A3'
      page.should have_content '15'
      page.should have_content 'Golden'
    end

    describe 'deleting a vehicle' do
      it 'should be able to delete a vehicle', js: true do
        visit root_path
        click_on 'All Vehicles'
        click_on '1M8GDM9AXKP042788'
        click_on 'Delete'
        alert = page.driver.browser.switch_to.alert
        alert.text.should eq('Are you sure you want to delete this vehicle?')
        alert.dismiss

        click_on 'Delete'
        alert = page.driver.browser.switch_to.alert
        alert.text.should eq('Are you sure you want to delete this vehicle?')
        alert.accept

        page.should have_content 'Vehicle number 987345 was successfully deleted'
        page.should have_content 'All Vehicles'
      end

      context 'when vehicle has one or more services', js: true do
        before do
          create(:service, vehicle: @vehicle1, customer: customer)

          visit root_path
          click_on 'All Vehicles'
          click_on '1M8GDM9AXKP042788'
          click_on 'Delete'
          alert = page.driver.browser.switch_to.alert
          alert.text.should eq('Are you sure you want to delete this vehicle?')
          alert.accept
        end

        it 'should prevent the deletion' do
          page.should have_content 'Vehicle has services assigned that you must remove before deleting the vehicle.'
        end

        it 'remain on the show page' do
          page.should have_content 'Show Vehicle'
        end
      end
    end

    it 'should be able to search vehicles' do
      visit root_path

      within '[data-vehicle-search-form]' do
        click_on 'Search'
      end

      page.should have_content 'Search Vehicles'

      page.should have_link 'Home'

      page.should have_link 'Create Vehicle'

      within 'table thead tr' do
        page.should have_link 'Vehicle Number'
        page.should have_link 'VIN'
        page.should have_link 'License Plate'
        page.should have_link 'Year'
        page.should have_link 'Make'
        page.should have_link 'Model'
        page.should have_link 'Mileage'
        page.should have_link 'Location'
        page.should have_link 'Status'
      end

      within 'table.sortable tbody tr:nth-of-type(1)' do
        page.should have_link '34987'
        page.should have_link '2B8GDM9AXKP042790'
        page.should have_content '123-ABC'
        page.should have_content '1999'
        page.should have_content 'Dodge'
        page.should have_content 'Dart'
        page.should have_content '20,000'
        page.should have_content 'Golden'
        page.should have_content 'N/A'
      end

      within 'table.sortable tbody tr:nth-of-type(2)' do
        page.should have_link '77777'
        page.should have_link '3C8GDM9AXKP042701'
        page.should have_content 'Buick'
      end

      within 'table.sortable tbody tr:nth-of-type(3)' do
        page.should have_link '987345'
        page.should have_link '1M8GDM9AXKP042788'
        page.should have_content 'Chevrolet'
      end

      fill_in 'Make', with: 'Chevro'
      click_on 'Search'

      page.should have_content 'Chevrolet'
      page.should_not have_content 'Buick'
      page.should_not have_content 'Dodge'

      within 'table thead tr' do
        page.should have_link 'Vehicle Number'
        page.should have_link 'VIN'
        page.should have_link 'License Plate'
        page.should have_link 'Year'
        page.should have_link 'Make'
        page.should have_link 'Model'
        page.should have_link 'Mileage'
        page.should have_link 'Location'
        page.should have_link 'Status'
      end

      fill_in 'Make', with: ''
      fill_in 'Model contains:', with: 'Riviera'
      click_on 'Search'

      page.should_not have_content 'Chevrolet'
      page.should have_content 'Buick'
      page.should_not have_content 'Dodge'

      fill_in 'Make', with: ''
      fill_in 'Model contains:', with: ''
      select 'Golden', from: 'location_id'
      click_on 'Search'

      page.should have_content 'Dodge'
      page.should_not have_content 'Chevrolet'
      page.should_not have_content 'Buick'

      fill_in 'Make', with: 'Chevro'
      fill_in 'Model contains:', with: 'Riviera'
      select 'Golden', from: 'location_id'
      click_on 'Search'

      page.should have_content 'Dodge'
      page.should have_content 'Chevrolet'
      page.should have_content 'Buick'
    end

    it 'should search and sort simultaneously', js: true do
      create(:vehicle, customer: customer, make: 'Unique Name')
      create(:vehicle, customer: customer, make: 'Zippy')

      visit '/'
      within '[data-vehicle-search-form]' do
        click_on 'Search'
      end

      page.should have_content 'Search Vehicle'
      page.should have_content 'Unique Name'
      page.should have_content 'Zippy'

      fill_in 'Make', with: 'Unique'

      click_on 'Search'

      page.should have_content 'Unique Name'
      page.should_not have_content 'Zippy'

      click_on 'Make'

      page.should have_content 'Unique Name'
      page.should_not have_content 'Zippy'
    end

    it 'should search from home page' do
      visit root_path

      within '[data-vehicle-search-form]' do
        fill_in 'make', with: 'Chevro'
        click_on 'Search'
      end

      page.should have_content 'Search Vehicles'

      page.should have_content 'Chevrolet'
      page.should_not have_content 'Buick'
      page.should_not have_content 'Dodge'
    end

    it 'should auto complete on make', js: true do
      create(:vehicle, make: 'Toyota', customer: customer)

      visit '/'
      click_on 'Search'

      assert_autocomplete('make', 'toy', 'Toyota')
    end

    it 'should auto complete on model', js: true do
      create(:vehicle, vehicle_model: 'Corolla', customer: customer)

      visit '/'
      click_on 'Search'

      assert_autocomplete('vehicle_model', 'cor', 'Corolla')
    end
  end

  context 'when an admin user' do
    let(:customer1) { create(:customer, name: 'Customer1') }
    let(:customer2) { create(:customer, name: 'Customer2') }

    before do
      create(:vehicle, vehicle_number: '987345', customer: customer1)
      create(:vehicle, vehicle_number: '34987', customer: customer2)
      create(:location, name: 'Golden')

      login_as_admin
    end

    it 'should list all vehicles for all customers' do
      click_link 'All Vehicles'

      page.should have_content '987345'
      page.should have_content '34987'
    end

    it 'should be able to create a new vehicle' do
      visit root_path

      page.should have_link 'Create Vehicle'

      click_on 'Create Vehicle'

      page.should have_content 'Create Vehicle'
      page.should have_link 'Home'
      page.should have_link 'Search Vehicles'

      fill_in 'Vehicle Number', with: '3921-A'
      fill_in 'VIN', with: '98765432109876543'
      fill_in 'License Plate', with: 'CTIsCool'
      fill_in 'Year', with: '2013'
      fill_in 'Make', with: 'Audi'
      fill_in 'Model', with: 'A3'
      fill_in 'Mileage', with: '15'
      select 'Golden', from: 'vehicle_location_id'

      click_on 'Create'

      page.should have_content 'Show Vehicle'
      page.should have_content 'Vehicle was successfully created'
      page.should have_content '3921-A'
      page.should have_content '98765432109876543'
      page.should have_content 'CTIsCool'
      page.should have_content '2013'
      page.should have_content 'Audi'
      page.should have_content 'A3'
      page.should have_content '15'
      page.should have_content 'Golden'
    end
  end

  context 'sorting' do
    before do
      login_as_vehicle_user(customer)
    end

    it 'should sort by vehicle_number' do
      zeta = create(:vehicle, vehicle_number: 'zeta', customer: customer)
      beta = create(:vehicle, vehicle_number: 'beta', customer: customer)
      alpha = create(:vehicle, vehicle_number: 'alpha', customer: customer)

      visit '/'
      click_link 'All Vehicles'

      # Ascending sort
      click_link 'Vehicle Number'
      column_data_should_be_in_order('alpha', 'beta', 'zeta')

      # Descending sort
      click_link 'Vehicle Number'
      column_data_should_be_in_order('zeta', 'beta', 'alpha')
    end

    it 'should sort by vin' do
      ZETA = create(:vehicle, vin: 'ZETA5678901234567', customer: customer)
      BETA = create(:vehicle, vin: 'BETA5678901234567', customer: customer)
      ALPHA = create(:vehicle, vin: 'ALPHA678901234567', customer: customer)

      visit '/'
      click_link 'All Vehicles'

      # Ascending sort
      click_link 'VIN'
      column_data_should_be_in_order('ALPHA678901234567', 'BETA5678901234567', 'ZETA5678901234567')

      # Descending sort
      click_link 'VIN'
      column_data_should_be_in_order('ZETA5678901234567', 'BETA5678901234567', 'ALPHA678901234567')
    end

    it 'should sort by license_plate' do
      zeta = create(:vehicle, license_plate: 'zeta', customer: customer)
      beta = create(:vehicle, license_plate: 'beta', customer: customer)
      alpha = create(:vehicle, license_plate: 'alpha', customer: customer)

      visit '/'
      click_link 'All Vehicles'

      # Ascending sort
      click_link 'License Plate'
      column_data_should_be_in_order('alpha', 'beta', 'zeta')

      # Descending sort
      click_link 'License Plate'
      column_data_should_be_in_order('zeta', 'beta', 'alpha')
    end

    it 'should sort by year' do
      zeta = create(:vehicle, year: '2013', customer: customer)
      beta = create(:vehicle, year: '1995', customer: customer)
      alpha = create(:vehicle, year: '1970', customer: customer)

      visit '/'
      click_link 'All Vehicles'

      # Ascending sort
      click_link 'Year'
      column_data_should_be_in_order(alpha.year, beta.year, zeta.year)

      # Descending sort
      click_link 'Year'
      column_data_should_be_in_order(zeta.year, beta.year, alpha.year)
    end

    it 'should sort by make' do
      zeta = create(:vehicle, make: 'zeta', customer: customer)
      beta = create(:vehicle, make: 'beta', customer: customer)
      alpha = create(:vehicle, make: 'alpha', customer: customer)

      visit '/'
      click_link 'All Vehicles'

      # Ascending sort
      click_link 'Make'
      column_data_should_be_in_order('alpha', 'beta', 'zeta')

      # Descending sort
      click_link 'Make'
      column_data_should_be_in_order('zeta', 'beta', 'alpha')
    end

    it 'should sort by vehicle_model' do
      zeta = create(:vehicle, vehicle_model: 'zeta', customer: customer)
      beta = create(:vehicle, vehicle_model: 'beta', customer: customer)
      alpha = create(:vehicle, vehicle_model: 'alpha', customer: customer)

      visit '/'
      click_link 'All Vehicles'

      # Ascending sort
      click_link 'Model'
      column_data_should_be_in_order('alpha', 'beta', 'zeta')

      # Descending sort
      click_link 'Model'
      column_data_should_be_in_order('zeta', 'beta', 'alpha')
    end

    it 'should sort by mileage' do
      zeta = create(:vehicle, mileage: 300, customer: customer)
      beta = create(:vehicle, mileage: 20000, customer: customer)
      alpha = create(:vehicle, mileage: 1000, customer: customer)

      visit '/'
      click_link 'All Vehicles'

      # Ascending sort
      click_link 'Mileage'
      column_data_should_be_in_order('300', '1,000', '20,000')

      # Descending sort
      click_link 'Mileage'
      column_data_should_be_in_order('20,000', '1,000', '300')
    end

    it 'should sort by location' do
      first_location = create(:location, name: 'Alcatraz')
      last_location = create(:location, name: 'Zurich')
      middle_location = create(:location, name: 'Burbank')

      create(:vehicle, location: first_location, customer: customer)
      create(:vehicle, location: last_location, customer: customer)
      create(:vehicle, location: middle_location, customer: customer)

      visit '/'
      click_link 'All Vehicles'

      click_link 'Location'
      column_data_should_be_in_order('Alcatraz', 'Burbank', 'Zurich')

      click_link 'Location'
      column_data_should_be_in_order('Zurich', 'Burbank', 'Alcatraz')
    end

    it 'should sort by status' do
      service_type = create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)
      vehicle_with_expired_service = create(:vehicle, customer: customer)
      create(:service, expiration_date: Date.yesterday, vehicle: vehicle_with_expired_service, service_type: service_type)
      vehicle_with_expiring_service = create(:vehicle, customer: customer)
      create(:service, expiration_date: Date.tomorrow, vehicle: vehicle_with_expiring_service, service_type: service_type)
      vehicle_with_valid_service = create(:vehicle, customer: customer)
      create(:service, expiration_date: Date.current+120.days, vehicle: vehicle_with_valid_service, service_type: service_type)
      vehicle_with_na_service = create(:vehicle, customer: customer)
      create(:service, expiration_date: nil, vehicle: vehicle_with_na_service, service_type: service_type)

      visit '/'
      click_link 'All Vehicles'

      click_link 'Status'
      column_data_should_be_in_order(Status::VALID.text, Status::EXPIRING.text, Status::EXPIRED.text, Status::NA.text)

      click_link 'Status'
      column_data_should_be_in_order(Status::NA.text, Status::EXPIRED.text, Status::EXPIRING.text, Status::VALID.text)
    end
  end

  context 'pagination' do
    before do
      login_as_vehicle_user(customer)
    end

    it 'should paginate' do
      55.times do
        create(:vehicle, customer: customer)
      end

      visit '/'
      click_link 'All Vehicles'

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