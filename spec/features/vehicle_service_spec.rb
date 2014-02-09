require 'spec_helper'

describe 'Vehicle Services', slow: true do
  describe 'Show Vehicle' do

    context 'sorting' do
      let(:customer) { create(:customer) }
      let(:vehicle) { create(:vehicle, customer: customer) }

      before do
        login_as_vehicle_user(customer)
      end

      it 'should sort by service type' do
        oil_change = create(:service_type, name: 'Oil change')
        tire_rotation = create(:service_type, name: 'Tire rotation')
        create(:service, vehicle: vehicle, service_type: tire_rotation)
        create(:service, vehicle: vehicle, service_type: oil_change)

        visit vehicle_path(vehicle)

        within '[data-vehicle-services] table thead tr:nth-of-type(1)' do
          click_link 'Service Type'
        end

        column_data_should_be_in_order('Oil change', 'Tire rotation')

        within '[data-vehicle-services] table thead tr:nth-of-type(1)' do
          click_link 'Service Type'
        end

        column_data_should_be_in_order('Tire rotation', 'Oil change')
      end

      it 'should sort by status' do
        expired_service_type = create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)
        warning_service_type = create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)
        valid_service_type = create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)
        create(:service, vehicle: vehicle, service_type: expired_service_type, expiration_date: Date.yesterday)
        create(:service, vehicle: vehicle, service_type: warning_service_type, expiration_date: Date.tomorrow)
        create(:service, vehicle: vehicle, service_type: valid_service_type, expiration_date: Date.today + 120.days)

        visit vehicle_path(vehicle)

        within '[data-vehicle-services] table thead tr:nth-of-type(1)' do
          click_link 'Status'
        end

        column_data_should_be_in_order('Valid','Warning','Expired')

        within '[data-vehicle-services] table thead tr:nth-of-type(1)' do
          click_link 'Status'
        end

        column_data_should_be_in_order('Expired','Warning', 'Valid')
      end
    end
  end
end