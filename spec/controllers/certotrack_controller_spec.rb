require 'spec_helper'

describe CertotrackController do

  let(:customer) { create(:customer, name: 'My Customer') }

  describe 'GET home' do
    context 'a user' do
      before do
        sign_in stub_equipment_user(customer)
      end

      it 'assigns first_name' do
        get :home

        assigns(:first_name).should == 'First'
      end

      it 'assigns customer_name' do
        get :home

        assigns(:customer_name).should == 'My Customer'
      end
    end

    context 'an equipment user' do
      let(:equipment_service) { EquipmentService.new }

      before do
        sign_in stub_equipment_user(customer)

        expired_equipment1 = double(expired?: true, expiring?: false)
        expired_equipment2 = double(expired?: true, expiring?: false)
        expiring_equipment = double(expiring?: true, expired?: false)
        equipment_service.stub(:get_all_equipment).and_return([expired_equipment1, expired_equipment2, expiring_equipment])
        equipment_service.stub(:count_expired_equipment).and_return(2)
        equipment_service.stub(:count_expiring_equipment).and_return(1)

        controller.load_equipment_service(equipment_service)
      end

      it 'assigns equipment counts' do
        get :home

        assigns(:total_equipment_count).should eq(3)
        assigns(:expired_equipment_count).should eq(2)
        assigns(:expiring_equipment_count).should eq(1)
      end

      it 'caches equipment counts' do
        get :home

        session[:total_equipment_count].should == 3
        session[:expired_equipment_count].should == 2
        session[:expiring_equipment_count].should == 1
      end

      it 'uses cache when available' do
        equipment_service.should_receive(:get_all_equipment)
        get :home

        equipment_service.should_not_receive(:get_all_equipment)
        get :home
      end
    end

    context 'an non-equipment user' do
      it 'assigns equipment counts' do
        sign_in stub_guest_user

        get :home

        assigns(:total_equipment_count).should be_nil
        assigns(:expired_equipment_count).should be_nil
        assigns(:expiring_equipment_count).should be_nil
      end
    end

    context 'a certification user' do
      let(:certification_service) { CertificationService.new }

      before do
        sign_in stub_certification_user(customer)
        expired_certification1 = double(expired?: true, expiring?: false, recertification_required?: false, units_based?: false)
        expired_certification2 = double(expired?: true, expiring?: false, recertification_required?: false, units_based?: false)
        expiring_certification = double(expiring?: true, expired?: false, recertification_required?: false, units_based?: false)
        recertification_certification = double(expiring?: false, expired?: false, recertification_required?: true, units_based?: false)
        units_based_certification = double(expiring?: false, expired?: false, recertification_required?: false, units_based?: true)
        certification_service.stub(:get_all_certifications).and_return(
          [expired_certification1, expired_certification2, expiring_certification, recertification_certification, units_based_certification]
        )
        controller.load_certification_service(certification_service)
      end

      it 'assigns certification counts' do
        get :home

        assigns(:total_certification_count).should eq(5)
        assigns(:total_recertification_required_certification_count).should eq(1)
        assigns(:total_units_based_certification_count).should eq(1)
        assigns(:total_expired_certification_count).should eq(2)
        assigns(:total_expiring_certification_count).should eq(1)
      end

      it 'caches certification counts' do
        get :home

        session[:total_certification_count].should eq(5)
        session[:total_recertification_required_certification_count].should eq(1)
        session[:total_units_based_certification_count].should eq(1)
        session[:total_expired_certification_count].should eq(2)
        session[:total_expiring_certification_count].should eq(1)
      end

      it 'uses cache when available' do
        certification_service.should_receive(:get_all_certifications)
        get :home

        certification_service.should_not_receive(:get_all_certifications)
        get :home
      end
    end

    context 'an non-certification user' do
      it 'assigns certification counts' do
        sign_in stub_guest_user

        get :home

        assigns(:total_certification_count).should be_nil
      end
    end

    context 'a vehicle user' do
      let(:vehicle_servicing_service) { VehicleServicingService.new }

      before do
        sign_in stub_vehicle_user(customer)

        expired_service1 = double(expired?: true, expiring?: false)
        expired_service2 = double(expired?: true, expiring?: false)
        expiring_service = double(expiring?: true, expired?: false)
        vehicle_servicing_service.stub(:get_all_services).and_return([expired_service1, expired_service2, expiring_service])
        controller.load_vehicle_servicing_service(vehicle_servicing_service)
      end

      it 'assigns service counts' do
        get :home

        assigns(:total_service_count).should == 3
        assigns(:total_expired_service_count).should == 2
        assigns(:total_expiring_service_count).should == 1
      end

      it 'caches service counts' do
        get :home

        session[:total_service_count].should == 3
        session[:total_expired_service_count].should == 2
        session[:total_expiring_service_count].should == 1
      end

      it 'uses cache when available' do
        vehicle_servicing_service.should_receive(:get_all_services)
        get :home

        vehicle_servicing_service.should_not_receive(:get_all_services)
        get :home
      end
    end

    context 'a non-vehicle user' do
      it 'assigns service counts' do
        sign_in stub_guest_user

        get :home

        assigns(:total_service_count).should be_nil
        assigns(:total_expired_service_count).should be_nil
        assigns(:total_expiring_service_count).should be_nil
      end
    end

    context 'an admin user' do
      it 'assigns customer_list' do
        my_admin_user = stub_admin
        sign_in my_admin_user

        get :home

        assigns(:customers).first.should be_a CustomerPresenter
        assigns(:customers).map(&:model).should == [my_admin_user.customer]
      end
    end

  end

  describe 'GET refresh' do
    it 'should clear out session counts' do
      sign_in stub_equipment_user(customer)
      session[:counts_cached] = true

      post :refresh, {}

      session[:counts_cached].should be_nil
    end

    it 'should redirect to the dashboard page' do
      sign_in stub_equipment_user(customer)

      post :refresh, {}

      response.should redirect_to(dashboard_path)
    end
  end
end
