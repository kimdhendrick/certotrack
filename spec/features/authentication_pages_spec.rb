require 'spec_helper'

describe 'Authentication', js:true do

  subject { page }

  describe 'signin' do

    before { visit '#welcome' }

    describe 'login page' do

      it { should have_content('Login') }
      it { should have_title('Certotrack') }
      it { should have_selector('input[type=submit]') }
    end

    describe 'with invalid information' do
      before { click_button 'Login' }

      it { should have_title('Certotrack') }
      it { should have_selector('div.alert', text: 'Invalid') }

      describe 'after visiting another page' do
        before { visit root_path }
        it { should have_selector('div.alert', text: 'You need to sign in or sign up before continuing.') }
      end
    end

    describe 'with valid information' do
      let(:user) { create_user }
      before do
        fill_in 'Username', with: user.username.upcase
        fill_in 'Password', with: user.password
        click_button 'Login'
      end

      it { should have_content('Welcome to Certotrack') }
      it { should have_selector("input[type=submit][value='Log out']") }
      it { should_not have_link('Login', href: 'login') }

      describe "followed by signout" do
        before { click_button "Log out" }
        it { should have_content('Login') }
        it { should have_selector('input[type=submit]') }
      end
    end
  end
end