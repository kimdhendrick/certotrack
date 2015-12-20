require 'spec_helper'

describe 'Users', slow: true do
  let(:jeffco) do
    create(
        :customer,
        name: 'Jefferson County',
        equipment_access: true,
        certification_access: false,
        vehicle_access: true
    )
  end

  before do
    regular_user = create(
        :user,
        customer: jeffco,
        username: 'joeuser',
        email: 'joe@user.com',
        first_name: 'Joe',
        last_name: 'User',
        admin: false,
        roles: ['equipment'],
    )
    login_as(regular_user)
  end

  describe 'All User List' do
    context 'all user list' do
      before do
        create(
            :user,
            first_name: 'Judith',
            last_name: 'Jones',
            username: 'judyjones',
            email: 'judy@jones.com',
            customer: jeffco,
            roles: jeffco.roles
        )

        denver = create(
            :customer,
            name: 'Denver',
            equipment_access: false,
            certification_access: true,
            vehicle_access: false
        )

        create(
            :user,
            first_name: 'Charles',
            last_name: 'Smith',
            username: 'charliesmith',
            email: 'charlie@smith.com',
            customer: denver,
            roles: denver.roles
        )
      end

      it 'should show only users for current customer in the All Users report' do
        visit dashboard_path
        page.should have_content 'All Users'
        click_link 'All Users'

        page.should have_content 'All Users'
        page.should have_content 'Total: 2'
        page.should have_link 'Home'

        within 'table thead tr' do
          page.should have_link 'Username'
          page.should have_link 'First Name'
          page.should have_link 'Last Name'
          page.should_not have_link 'Customer'
          page.should_not have_content 'Equipment Access'
          page.should_not have_content 'Certification Access'
          page.should_not have_content 'Vehicle Access'
        end

        within 'table tbody tr:nth-of-type(1)' do
          page.should have_link 'joeuser'
        end

        within 'table tbody tr:nth-of-type(2)' do
          page.should have_link 'judyjones'
          page.should have_content 'Judith'
          page.should have_content 'Jones'
          page.should_not have_link 'Jefferson County'
          page.should_not have_content /.*Yes.*No.*Yes.*/
        end

        page.should_not have_link 'charliesmith'
        page.should_not have_content 'Charles'
        page.should_not have_content 'Smith'
      end
    end
  end

  describe 'Show User' do
    it 'should show user details' do
      visit dashboard_path
      page.should have_content 'All Users'
      click_link 'All Users'

      page.should have_content 'All Users'

      click_on 'joeuser'

      page.should have_content 'Show User'

      page.should have_link 'Home'
      page.should have_link 'All Users'

      page.should have_content 'Name'
      page.should have_content 'Username'
      page.should have_content 'Email Address'
      page.should have_content 'Expiration Notification Interval'

      page.should have_content 'User, Joe'
      page.should have_content 'joeuser'
      page.should have_content 'Never'
    end
  end

  describe 'Create User' do
    it 'should create new user for own customer' do
      visit dashboard_path
      click_on 'All Users'

      click_on 'Create New User'

      page.should have_content 'Create User'

      page.should have_link 'Home'
      page.should have_link 'All Users'

      page.should have_content 'First name'
      page.should have_content 'Last name'
      page.should have_content 'Username'
      page.should have_content 'Password'
      page.should have_content 'Email address'
      page.should have_content 'Expiration notification interval'

      fill_in 'First name', with: 'Karen'
      fill_in 'Last name', with: 'Sandy'
      fill_in 'Username', with: 'sandylynn'
      fill_in 'Password', with: 'Password123'
      fill_in 'Email address', with: 'sandeelynn@faker.com'
      select 'Daily', from: 'Expiration notification interval'

      click_on 'Create'

      page.should have_content 'Show User'
      page.should have_content "User 'Sandy, Karen' was successfully created."

      page.should have_content 'Sandy, Karen'
      page.should have_content 'sandylynn'
      page.should have_content 'Daily'
    end
  end

  describe 'Update User' do
    it 'should edit user details' do
      create(
          :user,
          first_name: 'Kathy',
          last_name: 'Kramer',
          username: 'kkramer',
          email: 'kkramer@ejemplo.com',
          expiration_notification_interval: 'Weekly',
          customer: jeffco,
          roles: jeffco.roles
      )

      visit dashboard_path
      page.should have_content 'All Users'
      click_link 'All Users'

      page.should have_content 'All Users'

      click_on 'kkramer'

      page.should have_content 'Show User'

      page.should have_link 'Home'
      page.should have_link 'All Users'

      click_on 'Edit'

      page.should have_content 'Edit User'

      page.should have_content 'Home'
      page.should have_content 'All Users'

      page.should have_content 'First name'
      page.should have_content 'Last name'
      page.should have_content 'Username'
      page.should have_content 'Password'
      page.should have_content 'Email address'

      fill_in 'First name', with: 'Judith'
      fill_in 'Last name', with: 'Jones'
      fill_in 'Username', with: 'judyjones'
      fill_in 'Email address', with: 'jjones@example.com'
      select 'Weekly', from: 'Expiration notification interval'

      click_on 'Update'

      page.should have_content 'Show User'

      page.should have_content 'Jones, Judith'
      page.should have_content 'judyjones'
      page.should have_content 'jjones@example.com'
      page.should have_content 'Weekly'
    end
  end

  describe 'Delete User' do
    it 'should delete user from edit page', js: true do
      create(
          :user,
          first_name: 'Kathy',
          last_name: 'Kramer',
          username: 'kkramer',
          email: 'kkramer@ejemplo.com',
          expiration_notification_interval: 'Weekly',
          customer: jeffco,
          roles: jeffco.roles
      )

      visit dashboard_path
      page.should have_content 'All Users'
      click_link 'All Users'

      page.should have_content 'All Users'

      click_on 'kkramer'

      page.should have_content 'Show User'

      click_on 'Edit'
      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this user?')
      alert.dismiss

      page.should have_content 'Edit User'

      click_on 'Delete'

      page.driver.browser.switch_to.alert.accept

      page.should have_content 'All Users'
      page.should have_content "User 'Kramer, Kathy' was successfully deleted."
    end

    it 'should delete user from show page', js: true do
      create(
          :user,
          first_name: 'Kathy',
          last_name: 'Kramer',
          username: 'kkramer',
          email: 'kkramer@ejemplo.com',
          expiration_notification_interval: 'Weekly',
          customer: jeffco,
          roles: jeffco.roles
      )

      visit dashboard_path
      page.should have_content 'All Users'
      click_link 'All Users'

      page.should have_content 'All Users'

      click_on 'kkramer'

      page.should have_content 'Show User'

      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq 'Are you sure you want to delete this user?'
      alert.dismiss

      page.should have_content 'Show User'
      page.should have_content 'kkramer'

      click_on 'Delete'

      page.driver.browser.switch_to.alert.accept

      page.should have_content 'All Users'
      page.should have_content "User 'Kramer, Kathy' was successfully deleted."
    end
  end
end