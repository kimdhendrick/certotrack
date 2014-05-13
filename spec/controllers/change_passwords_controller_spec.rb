require 'spec_helper'

describe ChangePasswordsController do
  let(:user) { create(:user, password: 'OriginalPassword123', password_confirmation: 'OriginalPassword123') }

  before do
    stub_current_user_with(user)
    sign_in user
  end

  describe 'GET #edit' do
    it 'assigns user' do
      get :edit

      assigns(:user).should == user
    end
  end

  describe 'PUT #update_password' do
    describe 'with valid params' do
      let(:password_attributes) do
        {
          current_password: 'OriginalPassword123',
          password: 'Password123',
          password_confirmation: 'Password123'
        }
      end

      it 'updates the requested password' do
        previous_encrypted_password = user.encrypted_password

        patch :update_password, {:user => password_attributes}, {}

        user.reload.encrypted_password.should_not == previous_encrypted_password
      end

      it 'updates the password_changed_at time' do
        user.update_attribute(:password_changed_at, nil)
        user.password_changed_at.should be_nil

        patch :update_password, {:user => password_attributes}, {}

        user.reload.password_changed_at.should_not be_nil
      end

      it 'redirects to the home page' do
        patch :update_password, {:user => password_attributes}, {}

        response.should redirect_to root_path
        flash[:success].should == 'Password updated successfully.'
      end
    end

    describe 'with invalid params' do
      let(:bad_params) do
        {
          current_password: 'bad',
          password: 'bad',
          password_confirmation: 'bad'
        }
      end

      it 'assigns user' do
        patch :update_password, {:user => bad_params}, {}

        assigns(:user).should eq(user)
      end

      it "re-renders the 'edit' template" do
        patch :update_password, {:user => bad_params}, {}

        response.should render_template('edit')
      end
    end
  end
end