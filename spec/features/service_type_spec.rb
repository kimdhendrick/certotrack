require 'spec_helper'

describe 'Service Types', slow: true, js:true do

  let(:customer) { create(:customer) }

  context 'when an vehicle user' do
    before do
      create(:service_type, name: 'Oil change', expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE, interval_mileage: 5000, customer: customer)
      create(:service_type, name: 'Pump check', expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE, interval_mileage: 10000, interval_date: Interval::ONE_MONTH.text, customer: customer)
      create(:service_type, name: 'Tire rotation', expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE, interval_date: Interval::ONE_YEAR.text, customer: customer)

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
        # TODO
        #page.should have_link 'Oil change'
        page.should have_content 'Oil change'
        page.should have_content 'By Mileage'
        page.should have_content '5,000'
      end

      within 'table tbody tr:nth-of-type(2)' do
        # TODO
        #page.should have_link 'Pump check'
        page.should have_content 'Pump check'
        page.should have_content 'By Date and Mileage'
        page.should have_content '1 month'
        page.should have_content '10,000'
      end
    end
  end

  context 'when an admin user' do
    let(:customer1) { create(:customer, name: 'Customer1') }
    let(:customer2) { create(:customer, name: 'Customer2') }

    before do
      create(:service_type, name: 'Oil change', expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE, interval_mileage: 5000, customer: customer1)
      create(:service_type, name: 'Pump check', expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE, interval_mileage: 10000, interval_date: Interval::ONE_MONTH.text, customer: customer2)

      login_as_admin
    end

    it 'should list all service types for all customers' do
      click_link 'All Service Types'

      page.should have_content 'Oil change'
      page.should have_content 'Pump check'
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