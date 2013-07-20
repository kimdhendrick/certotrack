require 'spec_helper'

# Why does this test fail if js: false?  Has something to do with database_cleaner.
describe 'Authentication', js: true do

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
      it { should have_selector('div.alert.alert-error', text: 'Invalid') }

      describe 'after visiting another page' do
        before { visit root_path }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end

    describe 'with valid information' do
      let(:user) { User.create(first_name: 'Kim', last_name: 'last', email: 'email@email.com', password: 'password', password_confirmation: 'password') }
      before do
        fill_in 'Email', with: user.email.upcase
        fill_in 'Password', with: user.password
        click_button 'Login'
      end

      it { should have_content('Welcome to Certotrack') }
      it { should have_link('Log out', href: 'logout') }
      it { should_not have_link('Login', href: 'login') }

      describe "followed by signout" do
        before { click_link "Log out" }
        it { should have_content('Login') }
        it { should have_selector('input[type=submit]') }
      end
    end
  end
end