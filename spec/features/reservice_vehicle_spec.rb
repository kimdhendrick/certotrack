require 'spec_helper'

describe 'Reservice Vehicle Pages', slow: true do

  subject { page }

  let(:customer) { create(:customer) }
  let(:vehicle) do
    create(:vehicle, license_plate: '123-ABC', vehicle_number: '34987', year: 1999, vehicle_model: 'Dart')
  end
  let(:service_type) { create(:service_type, name: 'Oil change') }
  let(:service_period) do
    build(
      :service_period,
      start_mileage: 10001,
      start_date: Date.new(2013, 5, 16),
      comments: 'Best oil change evah!')
  end
  let(:service) { create(:service, customer: customer, vehicle: vehicle, service_type: service_type) }

  describe 'Show Service Page' do
    describe 'page' do
      before do
        login_as_vehicle_user(customer)
        visit service_path(service)
      end

      it { should have_link('Reservice', new_service_reservice_path(service)) }
    end
  end

  describe 'Reservice Vehicle Page' do

    before do
      service.service_periods << service_period
      service.active_service_period = service_period
      service.save!
      login_as_vehicle_user(customer)
      visit new_service_reservice_path(service)
    end

    describe 'page' do
      it { should have_selector('h1', text: 'Reservice Vehicle') }
      it { should have_link('Home', dashboard_path) }
      it { should have_link('Create Service', href: new_service_path) }
      it { should have_selector('div label', text: 'Vehicle') }
      it { should have_selector('div', text: '123-ABC/34987 1999 Dart') }
      it { should have_selector('div label', text: 'Service Type') }
      it { should have_selector('div', text: 'Oil change') }
      it { should have_selector('div', text: 'Oil change') }
      specify { find_field('Last Service Mileage').value.should == '10001' }
      specify { find_field('Last Service Date').value.should == '05/16/2013' }
      specify { find_field('Comments').value.should == 'Best oil change evah!' }
    end

    describe 'with invalid information' do
      before do
        click_button 'Reservice'
      end

      it { should have_selector('.errors') }
    end

    describe 'with valid information' do
      before do
        fill_in 'Last Service Mileage', with: 10000
        fill_in 'Last Service Date', with: '01/22/2014'
        fill_in 'Comments', with: 'Best oil change evah!'
      end

      it 'should create a new service_period' do
        expect { click_button('Reservice') }.to change(ServicePeriod, :count).by(1)
      end

      describe 'after saving' do
        before { click_button('Reservice') }

        it { should have_selector('h1', text: 'Show Service') }
      end
    end

    describe 'future last service date' do
      before do
        fill_in 'Last Service Mileage', with: 10000
        fill_in 'Last Service Date', with: '01/22/2055'
      end

      it 'should prompt user', js: true do
        click_on 'Reservice'

        alert = page.driver.browser.switch_to.alert
        alert.text.should eq('Are you sure you want to enter a future date?')
        alert.dismiss

        page.should have_content 'Reservice Vehicle'

        click_on 'Reservice'

        alert = page.driver.browser.switch_to.alert
        alert.text.should eq('Are you sure you want to enter a future date?')
        alert.accept

        page.should have_content 'Show Service'
      end
    end
  end
end
