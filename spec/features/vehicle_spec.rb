require 'spec_helper'

describe 'Vehicles', slow: true do

  let(:customer) { create(:customer) }

  context 'when an vehicle user' do
    before do
      denver = create(:location, name: 'Denver')
      golden = create(:location, name: 'Golden')
      boulder = create(:location, name: 'Boulder')

      create(:vehicle, vehicle_number: '987345', vin: '1M8GDM9AXKP042788', license_plate: 'ABC-123',
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
        page.should have_content '34987'
        #page.should have_link '34987'
        page.should have_content '2B8GDM9AXKP042790'
        #page.should have_link '2B8GDM9AXKP042790'
        page.should have_content '123-ABC'
        page.should have_content '1999'
        page.should have_content 'Dodge'
        page.should have_content 'Dart'
        page.should have_content '20,000'
        page.should have_content 'Golden'
        page.should have_content 'N/A'
      end

      within 'table tbody tr:nth-of-type(2)' do
        page.should have_content '77777'
        #page.should have_link '77777'
        page.should have_content '3C8GDM9AXKP042701'
        #page.should have_link '3C8GDM9AXKP042701'
        page.should have_content '789-XYZ'
        page.should have_content '1970'
        page.should have_content 'Buick'
        page.should have_content 'Riviera'
        page.should have_content '56,000'
        page.should have_content 'Boulder'
        page.should have_content 'N/A'
      end

      within 'table tbody tr:nth-of-type(3)' do
        page.should have_content '987345'
        #page.should have_link '987345'
        page.should have_content '1M8GDM9AXKP042788'
        #page.should have_link '1M8GDM9AXKP042788'
        page.should have_content 'ABC-123'
        page.should have_content '2013'
        page.should have_content 'Chevrolet'
        page.should have_content 'Chevette'
        page.should have_content '10,000'
        page.should have_content 'Denver'
        page.should have_content 'N/A'
      end
    end
  end

  context 'when an admin user' do
    let(:customer1) { create(:customer, name: 'Customer1') }
    let(:customer2) { create(:customer, name: 'Customer2') }

    before do
      create(:vehicle, vehicle_number: '987345', customer: customer1)
      create(:vehicle, vehicle_number: '34987', customer: customer2)

      login_as_admin
    end

    it 'should show all vehicles for all customers' do
      click_link 'All Vehicles'

      page.should have_content '987345'
      page.should have_content '34987'
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
      zeta = create(:vehicle, mileage: 300000, customer: customer)
      beta = create(:vehicle, mileage:  20000, customer: customer)
      alpha = create(:vehicle, mileage:  1000, customer: customer)

      visit '/'
      click_link 'All Vehicles'

      # Ascending sort
      click_link 'Mileage'
      column_data_should_be_in_order('1,000', '20,000', '300,000')

      # Descending sort
      click_link 'Mileage'
      column_data_should_be_in_order('300,000', '20,000', '1,000')
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

      # Ascending search
      click_link 'Location'
      column_data_should_be_in_order('Alcatraz', 'Burbank', 'Zurich')

      # Descending search
      click_link 'Location'
      column_data_should_be_in_order('Zurich', 'Burbank', 'Alcatraz')
    end
    
    xit 'should sort by status' do
      create(:expiring_vehicle, customer: customer)
      create(:expired_vehicle, customer: customer)
      create(:valid_vehicle, customer: customer)

      visit '/'
      click_link 'All Vehicles'

      # Ascending search
      click_link 'Status'
      column_data_should_be_in_order(Status::VALID.text, Status::EXPIRING.text, Status::EXPIRED.text)

      # Descending search
      click_link 'Status'
      column_data_should_be_in_order(Status::EXPIRED.text, Status::EXPIRING.text, Status::VALID.text)
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