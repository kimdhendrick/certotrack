require 'spec_helper'

describe 'Reservice Vehicle Pages' do

  subject { page }

  let(:customer) { create(:customer) }
  let(:vehicle) do
    create(:vehicle, license_plate: '123-ABC', vehicle_number: '34987', year: 1999, vehicle_model: 'Dart')
  end
  let(:service_type) { create(:service_type, name: 'Oil change')}
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

  describe 'Reservice Page' do

    before do
      login_as_vehicle_user(customer)
      visit new_service_reservice_path(service)
    end

    describe 'page' do
      it { should have_selector('h1', text: 'Reservice Vehicle') }
      it { should have_link('Home', root_path) }
      it { should have_link('Create Service', href: new_service_path) }
      it { should have_selector('span.label', text: 'Vehicle') }
      it { should have_selector('span.value', text: '123-ABC/34987 1999 Dart')}
      it { should have_selector('span.label', text: 'Service Type') }
      it { should have_selector('span.value', text: 'Oil change') }
    end

    describe 'with invalid information' do
      before do
        click_button 'Reservice'
      end

      it { should have_selector('#error_explanation') }
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
  end
end