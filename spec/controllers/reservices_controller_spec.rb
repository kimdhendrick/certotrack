require 'spec_helper'

describe ReservicesController do
  let(:customer) { create(:customer) }
  let(:service) { create(:service, customer: customer) }

  let(:user) { nil }

  before do
    sign_in user
  end

  describe 'new' do
    context 'when admin user' do
      let(:user) { stub_admin }
      before { get :new, {:service_id => service.to_param}, {} }
      specify { assigns(:service).should == service }
    end

    context 'when guest user' do
      let(:user) { stub_guest_user }
      before { get :new, {:service_id => service.to_param}, {} }
      specify { assigns(:service).should be_nil }
    end

    context 'when vehicle user' do
      let(:user) { stub_vehicle_user(customer) }
      before { get :new, {:service_id => service.to_param}, {} }
      specify { assigns(:service).should == service }
    end
  end

  describe 'create' do
    shared_examples_for 'an authorized action' do
      it 'should redirect to service when vehicle_servicing_service#reservice is successful' do
        Service.stub(:find).with(service.to_param).and_return(service)
        vehicle_servicing_service.stub(:reservice).with(
            service,
            'start_date' => '01/21/2014',
            'start_mileage' => '10000',
            'comments' => 'some comments'
        ).and_return(true)

        post :create, {
            :service_id => service.to_param,
            :start_date => '01/21/2014',
            :start_mileage => '10000',
            :comments => 'some comments'
        }

        response.should redirect_to(service)
      end

      it 'should render new template when vehicle_servicing_service#reservice is not successful' do
        vehicle_servicing_service.stub(:reservice).and_return(false)

        post :create, {
            :service_id => service.to_param,
            :start_date => '01/21/2014',
            :start_mileage => '10000',
            :comments => 'some comments'
        }

        response.should render_template('new')
      end
    end

    shared_examples_for 'an unauthorized action' do
      it 'should redirect to service when vehicle_servicing_service#reservice is successful' do
        post :create, {
            :service_id => service.to_param,
            :start_date => '01/21/2014',
            :start_mileage => '10000',
            :comments => 'some comments'
        }

        response.should redirect_to(root_url)
      end
    end

    let(:vehicle_servicing_service) { double('vehicle_servicing_service') }

    before { controller.load_vehicle_servicing_service(vehicle_servicing_service) }

    context 'when admin user' do
      let(:user) { stub_admin }
      it_behaves_like 'an authorized action'
    end

    context 'when guest user' do
      let(:user) { stub_guest_user }
      it_behaves_like 'an unauthorized action'
    end

    context 'when vehicle user' do
      let(:user) { stub_vehicle_user(customer) }
      it_behaves_like 'an authorized action'
    end
  end
end
