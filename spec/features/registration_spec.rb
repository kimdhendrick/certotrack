require 'spec_helper'

describe 'Registration', js: true, slow: true do
  it 'allow the user to register' do
    visit dashboard_path

    within '.top-bar' do
      click_on 'Sign Up'
      page.should have_content 'Sign Up'
    end

    visit dashboard_path

    click_on 'Sign Up'

    page.should have_content 'Sign Up'

    fill_in 'First name', with: 'Susie'
    fill_in 'Last name', with: 'Newbie'
    fill_in 'Enter Password', with: 'Password123!'
    fill_in 'Re-enter Password', with: 'Password123!'
    fill_in 'Customer name', with: 'New Customer'

    click_on 'Purchase Monthly Subscription'
  end
end