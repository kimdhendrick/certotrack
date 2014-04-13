require 'spec_helper'

describe RecertificationsController do

  let(:customer) { create(:customer) }
  let(:certification) { create(:certification, customer: customer) }

  describe 'GET new' do
    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns certification as @certification' do
        get :new, {:certification_id => certification.to_param}, {}
        assigns(:certification).should == certification
      end
    end

    context 'when guest user' do
      before { sign_in stub_guest_user }

      it 'does not assign certification' do
        get :new, {:certification_id => certification.to_param}, {}
        assigns(:certification).should be_nil
      end
    end

    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'assigns certification as @certification' do
        get :new, {:certification_id => certification.to_param}, {}
        assigns(:certification).should == certification
      end
    end
  end

  describe 'POST create' do
    let(:params) do
      {certification_id: certification.to_param}
    end
    let(:certification_service) { double('certification_service') }

    before do
      sign_in stub_admin
      controller.load_certification_service(certification_service)
      certification_service.stub(:recertify).and_return(true)
    end

    it 'should call CertificationService#recertify' do
      certification_service.should_receive('recertify')
      controller.load_certification_service(certification_service)
      post :create, params, {}
    end

    context 'on success' do
      it 'should redirect to certification' do
        post :create, params, {}
        response.should redirect_to(certification)
      end

      it 'should provide success message' do
        post :create, params, {}
        flash[:notice].should =~ /\ASmith, John was successfully recertified for Certification 'Scrum Master-\d+'\.\Z/
      end
    end

    context 'on error' do
      it 'should render recertify' do
        certification_service.stub(:recertify).and_return(false)
        post :create, params, {}
        response.should render_template('new')
      end
    end
  end
end