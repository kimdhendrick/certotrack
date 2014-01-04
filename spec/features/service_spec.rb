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
      within '[vehicle-services] table thead tr' do
        page.should have_content 'Service Type'
        page.should have_content 'Service Due Date'
        page.should have_content 'Service Due Mileage'
        page.should have_content 'Last Service Date'
        page.should have_content 'Last Service Mileage'
        page.should have_content 'Status'
      end

      within '[vehicle-services] table tbody tr:nth-of-type(1)' do
        page.should have_content 'Oil Change'
        #TODO show service
        #page.should have_link 'Oil Change'
        page.should have_content '07/01/2000'
        page.should have_content '14,000'
        page.should have_content '01/01/2000'
        page.should have_content '9,000'
        page.should have_content 'Expired'

        #TODO show service
        #click_link 'Oil Change'
        #page.should have_content 'Show Oil Change'
      end
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
end