require 'spec_helper'

describe RecertificationsController do

  let(:customer) { create(:customer) }

  describe 'GET new' do
    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns certification as @certification' do
        certification = create(:certification, customer: customer)
        get :new, {:certification_id => certification.to_param}, {}
        assigns(:certification).should == certification
      end
    end

    context 'when guest user' do
      before { sign_in stub_guest_user }

      it 'does not assign certification' do
        certification = create(:certification, customer: customer)
        get :new, {:certification_id => certification.to_param}, {}
        assigns(:certification).should be_nil
      end
    end

    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'assigns certification as @certification' do
        certification = create(:certification, customer: customer)
        get :new, {:certification_id => certification.to_param}, {}
        assigns(:certification).should == certification
      end
    end
  end
end
