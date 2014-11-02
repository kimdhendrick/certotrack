require 'spec_helper'

module Api
  describe SessionsController do
    describe 'POST #create' do
      let!(:user) do
        create(:user,
               username: 'iphone_user',
               password: 'Password123',
               first_name: 'Joe',
               last_name: 'Smith'
        )
      end

      describe 'with valid params' do
        let(:valid_params) do
          {
            'username' => 'iphone_user',
            'password' => 'Password123'
          }
        end

        it 'returns 200' do
          post :create, valid_params, {}

          response.status.should == 200
        end

        it 'returns success message' do
          post :create, valid_params, {}

          JSON.parse(response.body)['message'].should == 'success'
        end

        it 'returns first_name and last_name' do
          post :create, valid_params, {}

          JSON.parse(response.body)['first_name'].should == 'Joe'
          JSON.parse(response.body)['last_name'].should == 'Smith'
        end

        it 'sets the X-CSRF-Token token' do
          post :create, valid_params, {}

          response.headers['X-CSRF-Token'].should_not be_nil
          JSON.parse(response.body)['authenticity_token'].should_not be_nil
          response.headers['X-CSRF-Token'].should == JSON.parse(response.body)['authenticity_token']
        end
      end

      describe 'with Invalid params' do
        context 'when user does not exist' do
          it 'returns 401 and error message' do
            post :create, {'username' => 'blah', 'password' => 'blah'}, {}

            response.status.should == 401
            JSON.parse(response.body)['message'].should == 'Invalid username/password combination'
          end
        end

        context 'when username parameter not sent' do
          it 'returns 401 and error message' do
            post :create, {'password' => 'blah'}, {}

            response.status.should == 401
            JSON.parse(response.body)['message'].should == 'Invalid username/password combination'
          end
        end

        context 'when password parameter not sent' do
          it 'returns 401 and error message' do
            post :create, {'username' => 'blah'}, {}

            response.status.should == 401
            JSON.parse(response.body)['message'].should == 'Invalid username/password combination'
          end
        end

        context 'when wrong password is sent' do
          let(:invalid_params) do
            {
              'username' => 'iphone_user',
              'password' => 'blah'
            }
          end

          it 'returns 401 and error message' do
            post :create, invalid_params, {}

            response.status.should == 401
            JSON.parse(response.body)['message'].should == 'Invalid username/password combination'
          end
        end
      end
    end
  end
end

