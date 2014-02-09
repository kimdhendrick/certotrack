require 'spec_helper'

describe 'Services', slow: true do

  let(:customer) { create(:customer) }

  describe 'Service' do
    let!(:oil_change_service_type) do
      create(:service_type,
             name: 'Oil Change',
             expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE,
             interval_date: Interval::SIX_MONTHS.text,
             customer: customer
      )
    end

    let!(:truck_inspection_service_type) do
      create(:service_type,
             name: 'Level III Truck Service',
             expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE,
             interval_mileage: 3000,
             customer: customer
      )
    end

    let!(:vehicle) do
      create(:vehicle,
             license_plate: 'ABC-123',
             mileage: 100000,
             vehicle_number: 'JB3',
             make: 'Jeep',
             vehicle_model: 'Wrangler',
             customer_id: customer.id
      )
    end

    before do
      login_as_vehicle_user(customer)
      create(:service_type,
             name: 'Other service',
             expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE,
             interval_date: Interval::SIX_MONTHS.text,
             interval_mileage: 10000,
             customer: customer
      )
    end

    it 'should show service' do
      date_service = create(
        :service,
        vehicle: vehicle,
        service_type: oil_change_service_type,
        last_service_date: Date.new(2013, 1, 1),
        last_service_mileage: 1000,
        expiration_date: Date.new(2014, 1, 1),
        comments: 'Got pretty messy',
        customer: vehicle.customer
      )
      mileage_service = create(
        :service,
        vehicle: vehicle,
        service_type: truck_inspection_service_type,
        last_service_date: Date.new(2013, 1, 1),
        expiration_mileage: 1000,
        last_service_mileage: 500,
        comments: 'Got pretty messy',
        customer: vehicle.customer
      )
      date_and_mileage_service_type = create(
        :service_type,
        name: 'Pump Check',
        expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE,
        interval_date: Interval::SIX_MONTHS.text,
        interval_mileage: 5000,
        customer: customer
      )
      date_and_mileage_service = create(
        :service,
        vehicle: vehicle,
        service_type: date_and_mileage_service_type,
        last_service_date: Date.new(2013, 1, 1),
        last_service_mileage: 500,
        expiration_date: Date.new(2014, 1, 1),
        expiration_mileage: 1000,
        comments: 'Got pretty messy',
        customer: vehicle.customer
      )

      visit service_path date_and_mileage_service.id

      page.should have_content 'Show Service'

      page.should have_link 'Home'
      #TODO all service list
      #page.should have_link 'All Services'
      page.should have_link 'Create Service'
      page.should have_link 'Create Vehicle'

      page.should have_content 'Service Type'
      page.should have_content 'Vehicle'
      page.should have_content 'Status'
      page.should have_content 'Service Due Date'
      page.should have_content 'Service Due Mileage'
      page.should have_content 'Last Service Date'
      page.should have_content 'Last Service Mileage'
      page.should have_content 'Comments'

      page.should have_link 'Pump Check'
      page.should have_link 'ABC-123/JB3 2010 Wrangler'
      page.should have_content 'Expired'
      page.should have_content '01/01/2014'
      page.should have_content '1,000'
      page.should have_content '01/01/2013'
      page.should have_content '500'
      page.should have_content 'Got pretty messy'

      page.should have_link 'Edit'
      page.should have_link 'Delete'

      visit service_path date_service.id

      page.should have_content 'Show Service'

      page.should have_content 'Service Type'
      page.should have_content 'Vehicle'
      page.should have_content 'Status'
      page.should have_content 'Service Due Date'
      page.should_not have_content 'Service Due Mileage'
      page.should have_content 'Last Service Date'
      page.should have_content 'Last Service Mileage'
      page.should have_content 'Comments'

      page.should have_link 'Oil Change'
      page.should have_link 'ABC-123/JB3 2010 Wrangler'
      page.should have_content 'Expired'
      page.should have_content '01/01/2014'
      page.should have_content '01/01/2013'
      page.should have_content '1,000'
      page.should have_content 'Got pretty messy'

      visit service_path mileage_service.id

      page.should have_content 'Show Service'

      page.should have_content 'Service Type'
      page.should have_content 'Vehicle'
      page.should have_content 'Status'
      page.should_not have_content 'Service Due Date'
      page.should have_content 'Service Due Mileage'
      page.should have_content 'Last Service Date'
      page.should have_content 'Last Service Mileage'
      page.should have_content 'Comments'

      page.should have_link 'Level III Truck Service'
      page.should have_link 'ABC-123/JB3 2010 Wrangler'
      page.should have_content 'Expired'
      page.should have_content '1,000'
      page.should have_content '01/01/2013'
      page.should have_content '500'
      page.should have_content 'Got pretty messy'

    end

    it 'should edit service', js: true do
      service_type = create(
        :service_type,
        name: 'Tire Rotation',
        expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE,
        interval_date: Interval::SIX_MONTHS.text,
        interval_mileage: 5000,
        customer: customer
      )
      service = create(
        :service,
        vehicle: vehicle,
        service_type: service_type,
        last_service_date: Date.new(2013, 1, 1),
        last_service_mileage: 500,
        expiration_date: Date.new(2014, 1, 1),
        expiration_mileage: 1000,
        comments: 'Got pretty messy',
        customer: vehicle.customer
      )

      visit service_path service.id

      page.should have_content 'Show Service'

      click_on 'Edit'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to edit instead of reservice?')
      alert.dismiss

      page.should have_content 'Show Service'
      click_on 'Edit'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq 'Are you sure you want to edit instead of reservice?'
      alert.accept

      page.should have_content 'Edit Service'

      page.should have_link 'Home'
      #page.should have_link 'All Services'
      #page.should have_link 'Search Services'
      page.should have_link 'Create Service'

      page.should have_content 'Service Type'
      page.should have_content 'Vehicle'
      page.should have_content 'Last Service Date'
      page.should have_content 'Last Service Mileage'
      page.should have_content 'Comments'

      page.should have_field 'Service Type', with: service.service_type.id.to_s
      page.should have_link 'ABC-123/JB3 2010 Wrangler'
      page.should have_field 'Last Service Date' #, with: '01/01/2013'
      page.should have_field 'Comments' #, with: 'Got messier'

      page.should have_link 'Delete'

      select 'Oil Change', from: 'Service Type'
      fill_in 'Last Service Date', with: '01/07/2014'
      fill_in 'Last Service Mileage', with: '100000'

      click_on 'Update'

      page.should have_content 'Show Service Type'
      page.should have_content 'Service was successfully updated.'
      page.should have_content 'Oil Change'

      within '[data-serviced-vehicles] table tbody tr:nth-of-type(1)' do
        page.should have_link 'JB3'
        page.should have_content 'ABC-123'
        page.should have_link 'Edit'
      end

    end

    it 'should alert on future dates', js: true do
      visit vehicle_path vehicle.id

      page.should have_link 'New Vehicle Service'
      click_on 'New Vehicle Service'

      page.should have_content 'Create Service'

      select 'Oil Change', from: 'Service Type'
      fill_in 'Last Service Date', with: '01/01/2055'

      click_on 'Create'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to enter a future date?')
      alert.dismiss

      fill_in 'Last Service Date', with: '01/01/2055'

      click_on 'Save and Create Another'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to enter a future date?')
      alert.accept

      page.should have_content 'Create Service'
      page.should have_content 'Service: Oil Change created for Vehicle ABC-123/JB3 2010 Wrangler.'
    end

    it 'should give error if already certified' do
      create(:service, vehicle: vehicle, service_type: oil_change_service_type, customer: vehicle.customer)

      visit vehicle_path vehicle.id
      click_on 'New Vehicle Service'

      page.should have_content 'Create Service'

      select 'Oil Change', from: 'Service Type'
      fill_in 'Last Service Date', with: '01/01/2000'
      fill_in 'Last Service Mileage', with: '9000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Create Service'
      page.should have_content 'Service type already assigned to this Vehicle. Please update existing Service.'
    end
  end

  describe 'Service Vehicle from Show Vehicle page' do
    let!(:oil_change_service_type) do
      create(:service_type,
             name: 'Oil Change',
             expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE,
             interval_mileage: 5000,
             interval_date: Interval::SIX_MONTHS.text,
             customer: customer
      )
    end

    let!(:vehicle) do
      create(:vehicle,
             vehicle_number: 'JB3',
             license_plate: '123',
             make: 'Jeep',
             year: 2010,
             vehicle_model: 'Wrangler',
             customer_id: customer.id
      )
    end

    before do
      login_as_vehicle_user(customer)
      create(:service_type,
             name: 'Level III Truck Service',
             interval_date: Interval::SIX_MONTHS.text,
             expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE,
             customer: customer
      )

      create(:service_type,
             name: 'Other service',
             expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE,
             interval_mileage: 10000,
             customer: customer
      )
    end

    it 'should service vehicle' do
      visit vehicle_path vehicle.id

      page.should have_link 'New Vehicle Service'
      click_on 'New Vehicle Service'

      page.should have_content 'Create Service'

      page.should have_link 'Home'
      page.should have_link 'Create Service Type'
      page.should have_link 'Create Vehicle'

      page.should have_content 'Vehicle'
      page.should have_link '123/JB3 2010 Wrangler'
      page.should have_content 'Service Type'
      page.should have_content 'Create Service Type'
      page.should have_content 'Last Service Date'
      page.should have_content 'Comments'

      page.should have_button 'Create'
      page.should have_button 'Save and Create Another'

      select 'Oil Change', from: 'Service Type'
      fill_in 'Last Service Date', with: '01/01/2000'
      fill_in 'Last Service Mileage', with: '9000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Vehicle'
      page.should have_content 'Service: Oil Change created for Vehicle 123/JB3 2010 Wrangler.'

      page.should have_content 'Jeep'
      page.should have_content 'Wrangler'


      page.should have_content "Vehicle's Services"
      within '[data-vehicle-services] table thead tr' do
        page.should have_content 'Service Type'
        page.should have_content 'Service Due Date'
        page.should have_content 'Service Due Mileage'
        page.should have_content 'Last Service Date'
        page.should have_content 'Last Service Mileage'
        page.should have_content 'Status'
      end

      within '[data-vehicle-services] table tbody tr:nth-of-type(1)' do
        page.should have_link 'Oil Change'
        page.should have_content '07/01/2000'
        page.should have_content '14,000'
        page.should have_content '01/01/2000'
        page.should have_content '9,000'
        page.should have_content 'Expired'

        click_link 'Oil Change'
      end

      page.should have_content 'Show Service'
      page.should have_content 'Oil Change'
    end

    it 'should service vehicle and be ready to create another' do
      visit vehicle_path vehicle.id

      page.should have_link 'New Vehicle Service'
      click_on 'New Vehicle Service'

      page.should have_content 'Create Service'

      page.should have_link 'Home'
      page.should have_link 'Create Service Type'
      page.should have_link 'Create Vehicle'

      page.should have_content 'Vehicle'
      page.should have_link '123/JB3 2010 Wrangler'
      page.should have_content 'Service Type'
      page.should have_content 'Create Service Type'
      page.should have_content 'Last Service Date'
      page.should have_content 'Comments'

      page.should have_button 'Create'
      page.should have_button 'Save and Create Another'

      select 'Oil Change', from: 'Service Type'
      fill_in 'Last Service Date', with: '01/01/2000'
      fill_in 'Last Service Mileage', with: '9000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Save and Create Another'

      page.should have_content 'Create Service'
      page.should have_content 'Service: Oil Change created for Vehicle 123/JB3 2010 Wrangler.'

      page.should have_content 'Vehicle'
      page.should have_link '123/JB3 2010 Wrangler'
      page.should have_content 'Service Type'
      page.should have_content 'Create Service Type'
      page.should have_content 'Last Service Date'
      page.should have_content 'Comments'

      page.should have_button 'Create'
      page.should have_button 'Save and Create Another'

      select 'Level III Truck Service', from: 'Service Type'
      fill_in 'Last Service Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Vehicle'
      page.should have_content 'Service: Level III Truck Service created for Vehicle 123/JB3 2010 Wrangler.'
    end
  end

  describe 'Service Vehicle from Show Service Type page' do
    let!(:oil_change_service_type) do
      create(:service_type,
             name: 'Oil Change',
             interval_date: Interval::SIX_MONTHS.text,
             expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE,
             customer: customer
      )
    end

    let!(:vehicle) do
      create(:vehicle,
             license_plate: 'ABC-123',
             vehicle_number: 'JB3',
             make: 'Jeep',
             vehicle_model: 'Wrangler',
             customer_id: customer.id
      )
    end

    before do
      login_as_vehicle_user(customer)
      create(:service_type,
             name: 'AAA Truck Inspection',
             interval_date: Interval::SIX_MONTHS.text,
             expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE,
             customer: customer
      )

      create(:service_type,
             name: 'Other service',
             interval_date: Interval::SIX_MONTHS.text,
             expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE,
             customer: customer
      )
    end

    it 'should service vehicle' do
      visit service_type_path oil_change_service_type.id

      within 'tbody tr', text: 'JB3' do
        click_on 'Service'
      end

      page.should have_content 'Create Service'

      page.should have_link 'Home'
      page.should have_link 'Create Service Type'
      page.should have_link 'Create Vehicle'

      page.should have_content 'Vehicle'
      page.should have_link 'ABC-123/JB3 2010 Wrangler'
      page.should have_content 'Service Type'
      page.should have_link 'Create Service Type'
      page.should have_content 'Last Service Date'
      page.should have_content 'Last Service Mileage'
      page.should have_content 'Comments'

      page.should have_button 'Create'
      page.should have_button 'Save and Create Another'

      find_field('Service Type').value.should eq oil_change_service_type.id.to_s
      fill_in 'Last Service Date', with: '01/01/2000'
      fill_in 'Last Service Mileage', with: '2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Service Type'
      page.should have_content 'Service: Oil Change created for Vehicle ABC-123/JB3 2010 Wrangler.'
    end

    it 'should service vehicle and be ready to create another' do
      visit service_type_path oil_change_service_type.id

      within 'tbody tr', text: 'JB3' do
        click_on 'Service'
      end

      page.should have_content 'Create Service'

      fill_in 'Last Service Date', with: '01/01/2000'
      fill_in 'Last Service Mileage', with: '2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Save and Create Another'

      page.should have_content 'Create Service'
      page.should have_content 'Service: Oil Change created for Vehicle ABC-123/JB3 2010 Wrangler.'

      page.should have_content 'Vehicle'
      page.should have_link 'ABC-123/JB3 2010 Wrangler'
      page.should have_content 'Service Type'
      page.should have_content 'Create Service Type'
      page.should have_content 'Last Service Date'
      page.should have_content 'Last Service Mileage'
      page.should have_content 'Comments'

      page.should have_button 'Create'
      page.should have_button 'Save and Create Another'

      select 'AAA Truck Inspection', from: 'Service Type'
      fill_in 'Last Service Date', with: '01/01/2000'
      fill_in 'Last Service Mileage', with: '10000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Service Type'
      page.should have_content 'Service: AAA Truck Inspection created for Vehicle ABC-123/JB3 2010 Wrangler.'
    end
  end

  describe 'Delete Service' do
    before do
      login_as_vehicle_user(customer)
    end

    let(:service) do
      vehicle = create(
        :vehicle,
        license_plate: 'ABC-123',
        mileage: 100000,
        vehicle_number: 'JB3',
        make: 'Jeep',
        vehicle_model: 'Wrangler',
        customer_id: customer.id
      )

      service_type = create(
        :service_type,
        name: 'AAA Truck Inspection',
        interval_date: Interval::SIX_MONTHS.text,
        expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE,
        customer: customer
      )
      create(:service, vehicle: vehicle, service_type: service_type, customer: vehicle.customer)
    end

    it 'should delete existing service from show page', js: true do
      visit service_path service.id

      page.should have_content 'Show Service'
      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this service?')
      alert.dismiss

      page.should have_content 'Show Service'
      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this service?')
      alert.accept

      page.should have_content 'Show Service Type'
      page.should have_content 'Service AAA Truck Inspection for Vehicle ABC-123/JB3 2010 Wrangler deleted'
    end

    it 'should delete existing service from edit page', js: true do
      visit service_path service.id
      click_on 'Edit'

      page.driver.browser.switch_to.alert.accept

      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this service?')
      alert.dismiss

      page.should have_content 'Edit Service'
      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this service?')
      alert.accept

      page.should have_content 'Show Service Type'
      page.should have_content 'Service AAA Truck Inspection for Vehicle ABC-123/JB3 2010 Wrangler deleted'
    end
  end

  describe 'Service History' do
    let!(:oil_change_service_type) do
      create(:service_type,
             name: 'Oil Change',
             expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE,
             interval_date: Interval::SIX_MONTHS.text,
             interval_mileage: 3000,
             customer: customer
      )
    end

    let!(:tire_rotation_service_type) do
      create(:service_type,
             name: 'Tire Rotation',
             expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE,
             interval_date: Interval::SIX_MONTHS.text,
             interval_mileage: 3000,
             customer: customer
      )
    end

    let!(:mirror_cleaning_service_type) do
      create(:service_type,
             name: 'Mirror Cleaning',
             expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE,
             interval_date: Interval::SIX_MONTHS.text,
             interval_mileage: 3000,
             customer: customer
      )
    end

    let!(:vehicle) do
      create(:vehicle,
             license_plate: 'ABC-123',
             vehicle_number: 'Pinto 123',
             year: 1981,
             make: 'Pinto',
             vehicle_model: 'Pinto',
             customer_id: customer.id
      )
    end

    let(:oil_change) do
      oil_change = create(
        :service,
        vehicle: vehicle,
        service_type: oil_change_service_type,
        last_service_date: Date.new(2005, 1, 1),
        expiration_date: Date.new(2006, 1, 1),
        last_service_mileage: 1010,
        expiration_mileage: 2000,
        customer: vehicle.customer)
      create(:service_period,
             service: oil_change,
             start_date: Date.new(2004, 1, 1),
             end_date: Date.new(2005, 1, 1),
             start_mileage: 0,
             end_mileage: 1000
      )
      oil_change
    end

    let(:tire_rotation) do
      tire_rotation = create(
        :service,
        vehicle: vehicle,
        service_type: tire_rotation_service_type,
        last_service_date: Date.new(2005, 1, 1),
        expiration_date: Date.new(2006, 1, 1),
        last_service_mileage: 1010,
        expiration_mileage: 2000,
        customer: vehicle.customer)
      create(:service_period,
             service: tire_rotation,
             start_date: Date.new(2004, 1, 1),
             end_date: Date.new(2005, 1, 1),
             start_mileage: 0,
             end_mileage: 1000
      )
      tire_rotation
    end

    let(:mirror_cleaning) do
      mirror_cleaning = create(
        :service,
        vehicle: vehicle,
        service_type: mirror_cleaning_service_type,
        last_service_date: Date.new(2005, 1, 1),
        expiration_date: Date.new(2006, 1, 1),
        last_service_mileage: 1010,
        expiration_mileage: 2000,
        customer: vehicle.customer)
      create(:service_period,
             service: mirror_cleaning,
             start_date: Date.new(2004, 1, 1),
             end_date: Date.new(2005, 1, 1),
             start_mileage: 0,
             end_mileage: 1000
      )
      mirror_cleaning
    end

    before do
      login_as_vehicle_user(customer)
    end

    context 'date based service type', js:true do
      it 'should list historical services' do
        visit service_path(tire_rotation)

        page.should have_link 'Service History'
        click_on 'Service History'

        page.should have_content 'Show Service History'

        page.should have_content 'Vehicle'
        page.should have_content 'Service Type'
        page.should have_content 'Expiration Type'
        page.should have_content 'Interval Date'
        page.should_not have_content 'Interval Mileage'

        page.should have_link 'ABC-123/Pinto 123 1981 Pinto'
        page.should have_content 'By Date'
        page.should have_link 'Tire Rotation'
        page.should have_content '6 months'
        page.should_not have_content '3,000'

        page.should have_content 'Service History (Tire Rotation)'

        within '[data-historical] table thead tr' do
          page.should have_content 'Last Service Date'
          page.should have_content 'Expiration Date'
          page.should have_content 'Expiration Mileage'
          page.should have_content 'Status'
        end

        within '[data-historical] table tbody tr:nth-of-type(1)' do
          page.should have_content 'Active'
          page.should have_content '01/01/2005'
          page.should have_content '01/01/2006'
          page.should_not have_content '2,000'
          page.should have_content 'Expired'
        end

        within '[data-historical] table tbody tr:nth-of-type(2)' do
          page.should_not have_content 'Active'
          page.should have_content '01/01/2004'
          page.should have_content '01/01/2005'
          page.should_not have_content '1,000'
          page.should_not have_content 'Expired'
        end

        page.should have_link 'Back to service'
      end
    end

    context 'mileage based service type' do
      it 'should list historical services' do
        visit service_path(mirror_cleaning)

        page.should have_link 'Service History'
        click_on 'Service History'

        page.should have_content 'Show Service History'

        page.should have_content 'Vehicle'
        page.should have_content 'Service Type'
        page.should have_content 'Expiration Type'
        page.should_not have_content 'Interval Date'
        page.should have_content 'Interval Mileage'

        page.should have_link 'ABC-123/Pinto 123 1981 Pinto'
        page.should have_content 'By Mileage'
        page.should have_link 'Mirror Cleaning'
        page.should_not have_content '6 months'
        page.should have_content '3,000'

        page.should have_content 'Service History (Mirror Cleaning)'

        within '[data-historical] table thead tr' do
          page.should have_content 'Last Service Date'
          page.should have_content 'Expiration Date'
          page.should have_content 'Expiration Mileage'
          page.should have_content 'Status'
        end

        within '[data-historical] table tbody tr:nth-of-type(1)' do
          page.should have_content 'Active'
          page.should have_content '01/01/2005'
          page.should_not have_content '01/01/2006'
          page.should have_content '2,000'
          page.should have_content 'Expired'
        end

        within '[data-historical] table tbody tr:nth-of-type(2)' do
          page.should_not have_content 'Active'
          page.should have_content '01/01/2004'
          page.should_not have_content '01/01/2005'
          page.should have_content '1,000'
          page.should_not have_content 'Expired'
        end

        page.should have_link 'Back to service'
      end
    end

    context 'date and mileage based service type' do
      it 'should list historical services' do
        visit service_path(oil_change)

        page.should have_link 'Service History'
        click_on 'Service History'

        page.should have_content 'Show Service History'

        page.should have_content 'Vehicle'
        page.should have_content 'Service Type'
        page.should have_content 'Expiration Type'
        page.should have_content 'Interval Date'
        page.should have_content 'Interval Mileage'

        page.should have_link 'ABC-123/Pinto 123 1981 Pinto'
        page.should have_content 'By Date and Mileage'
        page.should have_link 'Oil Change'
        page.should have_content '6 months'
        page.should have_content '3,000'

        page.should have_content 'Service History (Oil Change)'

        within '[data-historical] table thead tr' do
          page.should have_content 'Last Service Date'
          page.should have_content 'Expiration Date'
          page.should have_content 'Expiration Mileage'
          page.should have_content 'Status'
        end

        within '[data-historical] table tbody tr:nth-of-type(1)' do
          page.should have_content 'Active'
          page.should have_content '01/01/2005'
          page.should have_content '01/01/2006'
          page.should have_content '2,000'
          page.should have_content 'Expired'
        end

        within '[data-historical] table tbody tr:nth-of-type(2)' do
          page.should_not have_content 'Active'
          page.should have_content '01/01/2004'
          page.should have_content '01/01/2005'
          page.should have_content '1,000'
          page.should_not have_content 'Expired'
        end

        page.should have_link 'Back to service'
      end
    end
  end
end