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
      it { should have_selector('div.alert', text: 'Invalid') }

      describe 'after visiting another page' do
        before { visit root_path }
        it { should_not have_selector('div.alert') }
      end
    end

    describe 'with valid information' do
      let(:user) { create_valid_user }
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