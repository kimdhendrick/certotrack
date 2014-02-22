require 'spec_helper'

describe 'Service Reports', slow: true do

  let(:customer) { create(:customer) }

  describe 'All Vehicle Services' do
    context 'when a vehicle user' do

      let!(:oil_change_service_type) do
        create(:service_type,
               name: 'Oil change',
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
      end

      it 'should list all vehicle services' do
        create(
          :service,
          vehicle: vehicle,
          service_type: oil_change_service_type,
          last_service_date: Date.new(2013, 1, 1),
          last_service_mileage: 1000,
          expiration_date: Date.new(2014, 1, 1),
          customer: vehicle.customer
        )
        create(
          :service,
          vehicle: vehicle,
          service_type: truck_inspection_service_type,
          last_service_date: Date.new(2013, 1, 1),
          last_service_mileage: 500,
          expiration_mileage: 1500,
          customer: vehicle.customer
        )

        visit '/'
        page.should have_content 'All Vehicle Services (2)'

        click_on 'All Vehicle Services (2)'
        page.should have_content 'All Vehicle Services'
        page.should have_content 'Total: 2'

        within 'table thead tr' do
          page.should have_link 'Service Type'
          page.should have_link 'Status'
          page.should have_link 'Vehicle'
          page.should have_link 'Vehicle Mileage'
          page.should have_link 'Service Due Date'
          page.should have_link 'Service Due Mileage'
          page.should have_link 'Last Service Date'
          page.should have_link 'Last Service Mileage'
        end

        within 'table tbody tr:nth-of-type(1)' do
          page.should have_link 'Level III Truck Service'
          page.should have_content 'Expired'
          page.should have_link 'ABC-123/JB3 2010 Wrangler'
          page.should have_content '100,000'
          # should not have service due date
          page.should have_content '1,500'
          page.should have_content '01/01/2013'
          page.should have_content '500'
        end

        within 'table tbody tr:nth-of-type(2)' do
          page.should have_link 'Oil change'
          page.should have_content 'Expired'
          page.should have_link 'ABC-123/JB3 2010 Wrangler'
          page.should have_content '100,000'
          page.should have_content '01/01/2014'
          # should not have service due mileage
          page.should have_content '01/01/2013'
          page.should have_content '1,000'
        end
      end
    end

    context 'sorting' do
      before do
        login_as_vehicle_user(customer)
      end

      it 'should sort by service type name' do
        zeta = create(:service_type, name: 'zeta', customer: customer)
        beta = create(:service_type, name: 'beta', customer: customer)
        alpha = create(:service_type, name: 'alpha', customer: customer)
        create(:service, service_type: zeta, customer: customer)
        create(:service, service_type: beta, customer: customer)
        create(:service, service_type: alpha, customer: customer)

        visit '/'
        click_link 'All Vehicle Services'

        # Ascending sort
        click_link 'Service Type'
        column_data_should_be_in_order('alpha', 'beta', 'zeta')

        # Descending sort
        click_link 'Service Type'
        column_data_should_be_in_order('zeta', 'beta', 'alpha')
      end

      it 'should sort by status' do
        expired = create(:service, expiration_date: Date.yesterday, customer: customer)
        warning = create(:service, expiration_date: Date.tomorrow, customer: customer)
        valid = create(:service, expiration_date: (Date.current)+120, customer: customer)

        visit '/'
        click_link 'All Vehicle Services'

        # Ascending sort
        click_link 'Status'
        column_data_should_be_in_order(valid.status, warning.status, expired.status)

        # Descending sort
        click_link 'Status'
        column_data_should_be_in_order(expired.status, warning.status, valid.status)
      end

      it 'should sort by vehicle' do
        zeta = create(:service, vehicle: create(:vehicle, license_plate: 'zeta'), customer: customer)
        beta = create(:service, vehicle: create(:vehicle, license_plate: 'beta'), customer: customer)
        alpha = create(:service, vehicle: create(:vehicle, license_plate: 'alpha'), customer: customer)

        visit '/'
        click_link 'All Vehicle Services'

        # Ascending sort
        click_link 'Vehicle'
        column_data_should_be_in_order(alpha.vehicle.license_plate, beta.vehicle.license_plate, zeta.vehicle.license_plate)

        # Descending sort
        click_link 'Vehicle'
        column_data_should_be_in_order(zeta.vehicle.license_plate, beta.vehicle.license_plate, alpha.vehicle.license_plate)
      end

      it 'should sort by vehicle mileage' do
        low = create(:service, vehicle: create(:vehicle, mileage: 1), customer: customer)
        high = create(:service, vehicle: create(:vehicle, mileage: 10000), customer: customer)
        middle = create(:service, vehicle: create(:vehicle, mileage: 100), customer: customer)

        visit '/'
        click_link 'All Vehicle Services'

        # Ascending sort
        click_link 'Vehicle Mileage'
        column_data_should_be_in_order('1', '100', '10,000')

        # Descending sort
        click_link 'Vehicle Mileage'
        column_data_should_be_in_order('10,000', '100', '1')
      end

      it 'should sort by last service date' do
        yesterday = create(:service, last_service_date: Date.parse('2013-12-31'), customer: customer).
          last_service_date.strftime("%m/%d/%Y")
        today = create(:service, last_service_date: Date.parse('2014-01-01'), customer: customer).
          last_service_date.strftime("%m/%d/%Y")
        tomorrow = create(:service, last_service_date: Date.parse('2014-01-02'), customer: customer).
          last_service_date.strftime("%m/%d/%Y")

        visit '/'
        click_link 'All Vehicle Services'

        # Ascending sort
        click_link 'Last Service Date'
        column_data_should_be_in_order(yesterday, today, tomorrow)

        # Descending sort
        click_link 'Last Service Date'
        column_data_should_be_in_order(tomorrow, today, yesterday)
      end

      it 'should sort by last service mileage' do
        low = create(:service, last_service_mileage: 1, customer: customer)
        middle = create(:service, last_service_mileage: 100, customer: customer)
        high = create(:service, last_service_mileage: 1000, customer: customer)

        visit '/'
        click_link 'All Vehicle Services'

        # Ascending sort
        click_link 'Last Service Mileage'
        column_data_should_be_in_order('1', '100', '1,000')

        # Descending sort
        click_link 'Last Service Mileage'
        column_data_should_be_in_order('1,000', '100', '1')
      end

      it 'should sort by service due date' do
        yesterday = create(:service, expiration_date: Date.parse('2013-12-31'), customer: customer).
          expiration_date.strftime("%m/%d/%Y")
        today = create(:service, expiration_date: Date.parse('2014-01-01'), customer: customer).
          expiration_date.strftime("%m/%d/%Y")
        tomorrow = create(:service, expiration_date: Date.parse('2014-01-02'), customer: customer).
          expiration_date.strftime("%m/%d/%Y")

        visit '/'
        click_link 'All Vehicle Services'

        # Ascending sort
        click_link 'Service Due Date'
        column_data_should_be_in_order(yesterday, today, tomorrow)

        # Descending sort
        click_link 'Service Due Date'
        column_data_should_be_in_order(tomorrow, today, yesterday)
      end

      it 'should sort by service due mileage' do
        low = create(:service, expiration_mileage: 1, customer: customer)
        middle = create(:service, expiration_mileage: 100, customer: customer)
        high = create(:service, expiration_mileage: 1000, customer: customer)

        visit '/'
        click_link 'All Vehicle Services'

        # Ascending sort
        click_link 'Service Due Mileage'
        column_data_should_be_in_order('1', '100', '1,000')

        # Descending sort
        click_link 'Service Due Mileage'
        column_data_should_be_in_order('1,000', '100', '1')
      end
    end

    context 'pagination' do
      before do
        login_as_vehicle_user(customer)
      end

      it 'should paginate' do
        55.times do
          create(:service, customer: customer)
        end

        visit '/'
        click_link 'All Vehicle Services (55)'

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

  describe 'Expired Vehicle Services' do
    context 'when a vehicle user' do

      let!(:oil_change_service_type) do
        create(:service_type,
               name: 'Oil change',
               expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE,
               interval_date: Interval::SIX_MONTHS.text,
               customer: customer
        )
      end

      let!(:tire_rotation_service_type) do
        create(:service_type,
               name: 'Tire rotation',
               expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE,
               interval_date: Interval::SIX_MONTHS.text,
               customer: customer
        )
      end

      let!(:air_check_service_type) do
        create(:service_type,
               name: 'Air check',
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
      end

      it 'should list only expired vehicle services' do
        valid_oil_change = create(
          :service,
          vehicle: vehicle,
          service_type: oil_change_service_type,
          last_service_date: Date.new(2013, 1, 1),
          last_service_mileage: 1000,
          expiration_date: Date.tomorrow+120,
          customer: vehicle.customer
        )
        expiring_tire_rotation = create(
          :service,
          vehicle: vehicle,
          service_type: tire_rotation_service_type,
          last_service_date: Date.new(2013, 1, 1),
          last_service_mileage: 1000,
          expiration_date: Date.tomorrow,
          customer: vehicle.customer
        )
        expired_air_check = create(
          :service,
          vehicle: vehicle,
          service_type: air_check_service_type,
          last_service_date: Date.new(2013, 1, 1),
          last_service_mileage: 1000,
          expiration_date: Date.yesterday,
          customer: vehicle.customer
        )
        expired_truck_inspection = create(
          :service,
          vehicle: vehicle,
          service_type: truck_inspection_service_type,
          last_service_date: Date.new(2013, 1, 1),
          last_service_mileage: 500,
          expiration_mileage: 1500,
          customer: vehicle.customer
        )

        visit '/'
        page.should have_content 'Expired Vehicle Services (2)'

        click_on 'Expired Vehicle Services (2)'
        page.should have_content 'Expired Vehicle Services'
        page.should have_content 'Total: 2'

        within 'table thead tr' do
          page.should have_link 'Service Type'
          page.should have_link 'Status'
          page.should have_link 'Vehicle'
          page.should have_link 'Vehicle Mileage'
          page.should have_link 'Service Due Date'
          page.should have_link 'Service Due Mileage'
          page.should have_link 'Last Service Date'
          page.should have_link 'Last Service Mileage'
        end

        within 'table tbody tr:nth-of-type(1)' do
          page.should have_link 'Air check'
          page.should have_content 'Expired'
          page.should have_link 'ABC-123/JB3 2010 Wrangler'
          page.should have_content '100,000'
          page.should have_content Date.yesterday.strftime("%m/%d/%Y")
          # should not have service due mileage
          page.should have_content '01/01/2013'
          page.should have_content '1,000'
        end

        within 'table tbody tr:nth-of-type(2)' do
          page.should have_link 'Level III Truck Service'
          page.should have_content 'Expired'
          page.should have_link 'ABC-123/JB3 2010 Wrangler'
          page.should have_content '100,000'
          # should not have service due date
          page.should have_content '1,500'
          page.should have_content '01/01/2013'
          page.should have_content '500'
        end
      end
    end

    context 'sorting' do
      before do
        login_as_vehicle_user(customer)
      end

      it 'should sort by service type name' do
        zeta = create(:service_type, name: 'zeta', customer: customer, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)
        beta = create(:service_type, name: 'beta', customer: customer, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)
        alpha = create(:service_type, name: 'alpha', customer: customer, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)
        create(:service, service_type: zeta, customer: customer, expiration_date: Date.yesterday)
        create(:service, service_type: beta, customer: customer, expiration_date: Date.yesterday)
        create(:service, service_type: alpha, customer: customer, expiration_date: Date.yesterday)

        visit '/'
        click_link 'Expired Vehicle Services'

        # Ascending sort
        click_link 'Service Type'
        column_data_should_be_in_order('alpha', 'beta', 'zeta')

        # Descending sort
        click_link 'Service Type'
        column_data_should_be_in_order('zeta', 'beta', 'alpha')
      end

      it 'should sort by vehicle' do
        zeta = create(:service,
                      vehicle: create(:vehicle, license_plate: 'zeta'),
                      service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
                      customer: customer,
                      expiration_date: Date.yesterday)
        beta = create(:service,
                      vehicle: create(:vehicle, license_plate: 'beta'),
                      service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
                      customer: customer,
                      expiration_date: Date.yesterday)
        alpha = create(:service,
                       vehicle: create(:vehicle, license_plate: 'alpha'),
                       service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
                       customer: customer,
                       expiration_date: Date.yesterday)

        visit '/'
        click_link 'Expired Vehicle Services'

        # Ascending sort
        click_link 'Vehicle'
        column_data_should_be_in_order(alpha.vehicle.license_plate, beta.vehicle.license_plate, zeta.vehicle.license_plate)

        # Descending sort
        click_link 'Vehicle'
        column_data_should_be_in_order(zeta.vehicle.license_plate, beta.vehicle.license_plate, alpha.vehicle.license_plate)
      end

      it 'should sort by vehicle mileage' do
        low = create(
          :service,
          vehicle: create(:vehicle, mileage: 1),
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.yesterday
        )
        high = create(
          :service,
          vehicle: create(:vehicle, mileage: 10000),
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.yesterday
        )
        middle = create(
          :service,
          vehicle: create(:vehicle, mileage: 100),
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.yesterday
        )

        visit '/'
        click_link 'Expired Vehicle Services'

        # Ascending sort
        click_link 'Vehicle Mileage'
        column_data_should_be_in_order('1', '100', '10,000')

        # Descending sort
        click_link 'Vehicle Mileage'
        column_data_should_be_in_order('10,000', '100', '1')
      end

      it 'should sort by last service date' do
        yesterday = create(
          :service,
          last_service_date: Date.parse('2013-12-31'),
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.yesterday
        ).last_service_date.strftime("%m/%d/%Y")

        today = create(
          :service,
          last_service_date: Date.parse('2014-01-01'),
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.yesterday
        ).last_service_date.strftime("%m/%d/%Y")

        tomorrow = create(
          :service,
          last_service_date: Date.parse('2014-01-02'),
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer, expiration_date: Date.yesterday
        ).last_service_date.strftime("%m/%d/%Y")

        visit '/'
        click_link 'Expired Vehicle Services'

        # Ascending sort
        click_link 'Last Service Date'
        column_data_should_be_in_order(yesterday, today, tomorrow)

        # Descending sort
        click_link 'Last Service Date'
        column_data_should_be_in_order(tomorrow, today, yesterday)
      end

      it 'should sort by last service mileage' do
        low = create(
          :service,
          last_service_mileage: 1,
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.yesterday
        )

        middle = create(
          :service,
          last_service_mileage: 100,
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.yesterday
        )

        high = create(
          :service,
          last_service_mileage: 1000,
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.yesterday
        )

        visit '/'
        click_link 'Expired Vehicle Services'

        # Ascending sort
        click_link 'Last Service Mileage'
        column_data_should_be_in_order('1', '100', '1,000')

        # Descending sort
        click_link 'Last Service Mileage'
        column_data_should_be_in_order('1,000', '100', '1')
      end

      it 'should sort by service due date' do
        yesterday = create(
          :service,
          expiration_date: Date.parse('2013-12-31'),
          customer: customer,
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          expiration_date: Date.yesterday
        ).expiration_date.strftime("%m/%d/%Y")

        today = create(
          :service,
          expiration_date: Date.parse('2014-01-01'),
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.yesterday
        ).expiration_date.strftime("%m/%d/%Y")

        tomorrow = create(
          :service,
          expiration_date: Date.parse('2014-01-02'),
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer, expiration_date: Date.yesterday
        ).expiration_date.strftime("%m/%d/%Y")

        visit '/'
        click_link 'Expired Vehicle Services'

        # Ascending sort
        click_link 'Service Due Date'
        column_data_should_be_in_order(yesterday, today, tomorrow)

        # Descending sort
        click_link 'Service Due Date'
        column_data_should_be_in_order(tomorrow, today, yesterday)
      end

      it 'should sort by service due mileage' do
        low = create(
          :service,
          expiration_mileage: 1,
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.yesterday
        )

        middle = create(
          :service,
          expiration_mileage: 100,
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.yesterday
        )

        high = create(
          :service,
          expiration_mileage: 1000,
          customer: customer,
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          expiration_date: Date.yesterday
        )

        visit '/'
        click_link 'Expired Vehicle Services'

        # Ascending sort
        click_link 'Service Due Mileage'
        column_data_should_be_in_order('1', '100', '1,000')

        # Descending sort
        click_link 'Service Due Mileage'
        column_data_should_be_in_order('1,000', '100', '1')
      end
    end

    context 'pagination' do
      before do
        login_as_vehicle_user(customer)
      end

      it 'should paginate' do
        55.times do
          create(:service, customer: customer,
                 service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
                 expiration_date: Date.yesterday)
        end

        visit '/'
        click_link 'Expired Vehicle Services (55)'

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

  describe 'Expiring Vehicle Services' do
    context 'when a vehicle user' do

      let!(:oil_change_service_type) do
        create(:service_type,
               name: 'Oil change',
               expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE,
               interval_date: Interval::SIX_MONTHS.text,
               customer: customer
        )
      end

      let!(:tire_rotation_service_type) do
        create(:service_type,
               name: 'Tire rotation',
               expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE,
               interval_date: Interval::SIX_MONTHS.text,
               customer: customer
        )
      end

      let!(:air_check_service_type) do
        create(:service_type,
               name: 'Air check',
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
               mileage: 1200,
               vehicle_number: 'JB3',
               make: 'Jeep',
               vehicle_model: 'Wrangler',
               customer_id: customer.id
        )
      end

      before do
        login_as_vehicle_user(customer)
      end

      it 'should list only Expiring vehicle services' do
        valid_oil_change = create(
          :service,
          vehicle: vehicle,
          service_type: oil_change_service_type,
          last_service_date: Date.new(2013, 1, 1),
          last_service_mileage: 1000,
          expiration_date: Date.tomorrow+120,
          customer: vehicle.customer
        )
        expired_tire_rotation = create(
          :service,
          vehicle: vehicle,
          service_type: tire_rotation_service_type,
          last_service_date: Date.new(2013, 1, 1),
          last_service_mileage: 1000,
          expiration_date: Date.yesterday,
          customer: vehicle.customer
        )
        expiring_air_check = create(
          :service,
          vehicle: vehicle,
          service_type: air_check_service_type,
          last_service_date: Date.new(2013, 1, 1),
          last_service_mileage: 1000,
          expiration_date: Date.tomorrow,
          customer: vehicle.customer
        )
        expiring_truck_inspection = create(
          :service,
          vehicle: vehicle,
          service_type: truck_inspection_service_type,
          last_service_date: Date.new(2013, 1, 1),
          last_service_mileage: 500,
          expiration_mileage: 1500,
          customer: vehicle.customer
        )

        visit '/'
        page.should have_content 'Expiring Vehicle Services (2)'

        click_on 'Expiring Vehicle Services (2)'
        page.should have_content 'Expiring Vehicle Services'
        page.should have_content 'Total: 2'

        within 'table thead tr' do
          page.should have_link 'Service Type'
          page.should have_link 'Status'
          page.should have_link 'Vehicle'
          page.should have_link 'Vehicle Mileage'
          page.should have_link 'Service Due Date'
          page.should have_link 'Service Due Mileage'
          page.should have_link 'Last Service Date'
          page.should have_link 'Last Service Mileage'
        end

        within 'table tbody tr:nth-of-type(1)' do
          page.should have_link 'Air check'
          page.should have_content 'Warning'
          page.should have_link 'ABC-123/JB3 2010 Wrangler'
          page.should have_content '1,200'
          page.should have_content Date.tomorrow.strftime("%m/%d/%Y")
          # should not have service due mileage
          page.should have_content '01/01/2013'
          page.should have_content '1,000'
        end

        within 'table tbody tr:nth-of-type(2)' do
          page.should have_link 'Level III Truck Service'
          page.should have_content 'Warning'
          page.should have_link 'ABC-123/JB3 2010 Wrangler'
          page.should have_content '1,200'
          # should not have service due date
          page.should have_content '1,500'
          page.should have_content '01/01/2013'
          page.should have_content '500'
        end
      end
    end

    context 'sorting' do
      before do
        login_as_vehicle_user(customer)
      end

      it 'should sort by service type name' do
        zeta = create(:service_type, name: 'zeta', customer: customer, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)
        beta = create(:service_type, name: 'beta', customer: customer, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)
        alpha = create(:service_type, name: 'alpha', customer: customer, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)
        create(:service, service_type: zeta, customer: customer, expiration_date: Date.tomorrow)
        create(:service, service_type: beta, customer: customer, expiration_date: Date.tomorrow)
        create(:service, service_type: alpha, customer: customer, expiration_date: Date.tomorrow)

        visit '/'
        click_link 'Expiring Vehicle Services'

        # Ascending sort
        click_link 'Service Type'
        column_data_should_be_in_order('alpha', 'beta', 'zeta')

        # Descending sort
        click_link 'Service Type'
        column_data_should_be_in_order('zeta', 'beta', 'alpha')
      end

      it 'should sort by vehicle' do
        zeta = create(:service,
                      vehicle: create(:vehicle, license_plate: 'zeta'),
                      service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
                      customer: customer,
                      expiration_date: Date.tomorrow)
        beta = create(:service,
                      vehicle: create(:vehicle, license_plate: 'beta'),
                      service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
                      customer: customer,
                      expiration_date: Date.tomorrow)
        alpha = create(:service,
                       vehicle: create(:vehicle, license_plate: 'alpha'),
                       service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
                       customer: customer,
                       expiration_date: Date.tomorrow)

        visit '/'
        click_link 'Expiring Vehicle Services'

        # Ascending sort
        click_link 'Vehicle'
        column_data_should_be_in_order(alpha.vehicle.license_plate, beta.vehicle.license_plate, zeta.vehicle.license_plate)

        # Descending sort
        click_link 'Vehicle'
        column_data_should_be_in_order(zeta.vehicle.license_plate, beta.vehicle.license_plate, alpha.vehicle.license_plate)
      end

      it 'should sort by vehicle mileage' do
        low = create(
          :service,
          vehicle: create(:vehicle, mileage: 1),
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.tomorrow
        )
        high = create(
          :service,
          vehicle: create(:vehicle, mileage: 10000),
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.tomorrow
        )
        middle = create(
          :service,
          vehicle: create(:vehicle, mileage: 100),
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.tomorrow
        )

        visit '/'
        click_link 'Expiring Vehicle Services'

        # Ascending sort
        click_link 'Vehicle Mileage'
        column_data_should_be_in_order('1', '100', '10,000')

        # Descending sort
        click_link 'Vehicle Mileage'
        column_data_should_be_in_order('10,000', '100', '1')
      end

      it 'should sort by last service date' do
        yesterday = create(
          :service,
          last_service_date: Date.parse('2013-12-31'),
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.tomorrow
        ).last_service_date.strftime("%m/%d/%Y")

        today = create(
          :service,
          last_service_date: Date.parse('2014-01-01'),
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.tomorrow
        ).last_service_date.strftime("%m/%d/%Y")

        tomorrow = create(
          :service,
          last_service_date: Date.parse('2014-01-02'),
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer, expiration_date: Date.tomorrow
        ).last_service_date.strftime("%m/%d/%Y")

        visit '/'
        click_link 'Expiring Vehicle Services'

        # Ascending sort
        click_link 'Last Service Date'
        column_data_should_be_in_order(yesterday, today, tomorrow)

        # Descending sort
        click_link 'Last Service Date'
        column_data_should_be_in_order(tomorrow, today, yesterday)
      end

      it 'should sort by last service mileage' do
        low = create(
          :service,
          last_service_mileage: 1,
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.tomorrow
        )

        middle = create(
          :service,
          last_service_mileage: 100,
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.tomorrow
        )

        high = create(
          :service,
          last_service_mileage: 1000,
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.tomorrow
        )

        visit '/'
        click_link 'Expiring Vehicle Services'

        # Ascending sort
        click_link 'Last Service Mileage'
        column_data_should_be_in_order('1', '100', '1,000')

        # Descending sort
        click_link 'Last Service Mileage'
        column_data_should_be_in_order('1,000', '100', '1')
      end

      it 'should sort by service due date' do
        yesterday = create(
          :service,
          expiration_date: Date.parse('2013-12-31'),
          customer: customer,
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          expiration_date: Date.tomorrow
        ).expiration_date.strftime("%m/%d/%Y")

        today = create(
          :service,
          expiration_date: Date.parse('2014-01-01'),
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.tomorrow
        ).expiration_date.strftime("%m/%d/%Y")

        tomorrow = create(
          :service,
          expiration_date: Date.parse('2014-01-02'),
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer, expiration_date: Date.tomorrow
        ).expiration_date.strftime("%m/%d/%Y")

        visit '/'
        click_link 'Expiring Vehicle Services'

        # Ascending sort
        click_link 'Service Due Date'
        column_data_should_be_in_order(yesterday, today, tomorrow)

        # Descending sort
        click_link 'Service Due Date'
        column_data_should_be_in_order(tomorrow, today, yesterday)
      end

      it 'should sort by service due mileage' do
        low = create(
          :service,
          expiration_mileage: 1,
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.tomorrow
        )

        middle = create(
          :service,
          expiration_mileage: 100,
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          customer: customer,
          expiration_date: Date.tomorrow
        )

        high = create(
          :service,
          expiration_mileage: 1000,
          customer: customer,
          service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
          expiration_date: Date.tomorrow
        )

        visit '/'
        click_link 'Expiring Vehicle Services'

        # Ascending sort
        click_link 'Service Due Mileage'
        column_data_should_be_in_order('1', '100', '1,000')

        # Descending sort
        click_link 'Service Due Mileage'
        column_data_should_be_in_order('1,000', '100', '1')
      end
    end

    context 'pagination' do
      before do
        login_as_vehicle_user(customer)
      end

      it 'should paginate' do
        55.times do
          create(:service, customer: customer,
                 service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE),
                 expiration_date: Date.tomorrow)
        end

        visit '/'
        click_link 'Expiring Vehicle Services (55)'

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
end