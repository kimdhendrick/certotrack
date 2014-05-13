require 'spec_helper'

describe 'Password Security', slow: true do
  let(:user) { create(:user, password: 'Password123', password_confirmation: 'Password123') }

  context 'authenticated user' do
    it 'should allow user to change their password', js: true do
      login_as(user)

      click_on 'Change Password'

      page.should have_content 'Change Password'
      fill_in 'Current Password', with: 'PasswordBAD'
      fill_in 'New Password', with: 'password123'
      fill_in 'Confirm New Password', with: 'password123'
      click_on 'Change Password'
      page.should have_content 'Current password is invalid'

      fill_in 'Current Password', with: 'Password123'
      fill_in 'New Password', with: 'password123'
      fill_in 'Confirm New Password', with: 'password123'
      click_on 'Change Password'
      page.should have_content 'Password must be at least 8 characters long and must contain at least one digit and combination of upper and lower case.'

      fill_in 'Current Password', with: 'Password123'
      fill_in 'New Password', with: 'Password555'
      fill_in 'Confirm New Password', with: 'Password666'
      click_on 'Change Password'
      page.should have_content "Password confirmation doesn't match Password"

      fill_in 'Current Password', with: 'Password123'
      fill_in 'New Password', with: 'Password321'
      fill_in 'Confirm New Password', with: 'Password321'
      click_on 'Change Password'

      page.should have_content 'Password updated successfully.'
      page.should have_content 'Welcome'
    end
  end

  context 'when user with an expired password' do
    before do
      user.update_attribute(:password_changed_at, 91.days.ago)
    end

    it 'should force the user to change their password to a valid one' do
      login_as(user)

      page.should have_field 'password'
      page.should have_content 'Renew your password'
      page.should have_button 'Change my password'

      page.fill_in 'Current password', with: 'Password123'
      page.fill_in 'New password', with: 'p'
      page.fill_in 'Confirm new password', with: 'p'
      click_on 'Change my password'

      page.should have_content 'Password must be at least 8 characters long and must contain at least one digit and combination of upper and lower case.'

      page.fill_in 'Current password', with: 'Password123'
      page.fill_in 'New password', with: 'password123'
      page.fill_in 'Confirm new password', with: 'password123'
      click_on 'Change my password'

      page.should have_content 'Password must be at least 8 characters long and must contain at least one digit and combination of upper and lower case.'

      page.fill_in 'Current password', with: 'Password123'
      page.fill_in 'New password', with: 'Password123'
      page.fill_in 'Confirm new password', with: 'Password123'
      click_on 'Change my password'

      page.should have_content 'Password may not be the same as current password.'
      page.should have_content 'Password may not be one used recently.'

      page.fill_in 'Current password', with: 'Password123'
      page.fill_in 'New password', with: 'Password1234'
      page.fill_in 'Confirm new password', with: 'Password1234'
      click_on 'Change my password'

      page.should have_content 'Welcome'
    end
  end
end