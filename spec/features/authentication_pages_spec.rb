require 'spec_helper'

describe 'Authentication', slow: true do

  subject { page }

  describe 'signin' do

    before { visit '/dashboard' }

    describe 'login page' do

      it { should have_title('Certotrack') }
      it { should have_content('Username') }
      it { should have_content('Password') }
      it { should have_selector('input[type=submit]') }
    end

    describe 'with invalid information' do
      before { click_on 'Login' }

      it { should have_title('Certotrack') }
      it { should have_selector('div.alert', text: 'Invalid') }

      describe 'after visiting another page' do
        before { visit dashboard_path }
        it { should have_selector('div.alert', text: 'You need to sign in before continuing.') }
      end
    end

    describe 'with valid information' do
      let(:user) { create(:user) }
      before do
        fill_in 'Username', with: user.username.upcase
        fill_in 'Password', with: user.password
        click_on 'Login'
      end

      it { should have_content('Welcome to CertoTrack') }
      it { should have_link 'Log out' }
      it { should_not have_link('Login', href: 'login') }

      describe 'followed by signout' do
        before { click_on 'Log out' }
        it { should have_title('Certotrack') }
        it { should have_content('Username') }
        it { should have_content('Password') }
        it { should have_selector('input[type=submit]') }
      end
    end
  end
end