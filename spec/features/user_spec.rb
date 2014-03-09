require 'spec_helper'

describe 'Users', slow: true do
  before do
    admin_user = create(
      :user,
      username: 'admin',
      first_name: 'Adam',
      last_name: 'Admin',
      admin: true
    )

    login_as(admin_user)
  end

  describe 'All User List' do
    it 'should show All Users report' do
      jeffco = create(
        :customer,
        name: 'Jefferson County',
        equipment_access: true,
        certification_access: false,
        vehicle_access: true
      )

      create(
        :user,
        first_name: 'Judith',
        last_name: 'Jones',
        username: 'judyjones',
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
        customer: denver,
        roles: denver.roles
      )

      visit '/'
      page.should have_content 'All Users'
      click_link 'All Users'

      page.should have_content 'All Users'
      page.should have_content 'Total: 3'
      page.should have_link 'Home'

      within 'table thead tr' do
        page.should have_link 'Username'
        page.should have_link 'First Name'
        page.should have_link 'Last Name'
        page.should have_link 'Customer'
        page.should have_content 'Equipment Access'
        page.should have_content 'Certification Access'
        page.should have_content 'Vehicle Access'
      end

      within 'table tbody tr:nth-of-type(1)' do
        page.should have_link 'admin'
      end

      within 'table tbody tr:nth-of-type(2)' do
        page.should have_link 'charliesmith'
        page.should have_content 'Charles'
        page.should have_content 'Smith'
        page.should have_link 'Denver'
        page.should have_content /.*No.*Yes.*No.*/
      end

      within 'table tbody tr:nth-of-type(3)' do
        page.should have_link 'judyjones'
        page.should have_content 'Judith'
        page.should have_content 'Jones'
        page.should have_link 'Jefferson County'
        page.should have_content /.*Yes.*No.*Yes.*/
      end
    end

    context 'sorting' do
      it 'should sort by username' do
        create(:user, first_name: 'zeta')
        create(:user, first_name: 'beta')
        create(:user, first_name: 'alpha')

        visit '/'
        click_link 'All Users'

        # Ascending search
        click_link 'First Name'
        column_data_should_be_in_order('admin', 'alpha', 'beta', 'zeta')

        # Descending search
        click_link 'First Name'
        column_data_should_be_in_order('zeta', 'beta', 'alpha', 'admin')
      end

      it 'should sort by first name' do
        create(:user, first_name: 'zeta')
        create(:user, first_name: 'beta')
        create(:user, first_name: 'alpha')

        visit '/'
        click_link 'All Users'

        # Ascending search
        click_link 'First Name'
        column_data_should_be_in_order('Adam', 'alpha', 'beta', 'zeta')

        # Descending search
        click_link 'First Name'
        column_data_should_be_in_order('zeta', 'beta', 'alpha', 'Adam')
      end

      it 'should sort by last name' do
        create(:user, last_name: 'zeta')
        create(:user, last_name: 'beta')
        create(:user, last_name: 'alpha')

        visit '/'
        click_link 'All Users'

        # Ascending search
        click_link 'Last Name'
        column_data_should_be_in_order('Admin', 'alpha', 'beta', 'zeta')

        # Descending search
        click_link 'Last Name'
        column_data_should_be_in_order('zeta', 'beta', 'alpha', 'Admin')
      end

      it 'should sort by customer' do
        zeta_customer = create(:customer, name: 'zeta')
        beta_customer = create(:customer, name: 'beta')
        alpha_customer = create(:customer, name: 'alpha')

        create(:user, customer: zeta_customer)
        create(:user, customer: beta_customer)
        create(:user, customer: alpha_customer)

        visit '/'
        click_link 'All Users'

        # Ascending search
        click_link 'Customer'
        column_data_should_be_in_order('alpha', 'beta', 'My Customer', 'zeta')

        # Descending search
        click_link 'Customer'
        column_data_should_be_in_order('zeta', 'My Customer', 'beta', 'alpha')
      end
    end

    context 'pagination' do
      it 'should paginate All Users report' do
        55.times do
          create(:user)
        end

        visit '/'
        click_link 'All Users'

        find 'table.sortable'

        page.all('table tr').count.should == 25 + 1
        within 'div.pagination' do
          page.should_not have_link 'Previous'
          page.should_not have_link '1'
          page.should have_link '2'
          page.should have_link '3'
          page.should have_link 'Next'
        end

        click_link 'Next'

        page.all('table tr').count.should == 25 + 1
        within 'div.pagination' do
          page.should have_link 'Previous'
          page.should have_link '1'
          page.should_not have_link '2'
          page.should have_link '3'
          page.should have_link 'Next'
        end

        click_link 'Next'

        page.all('table tr').count.should == 5 + 1 + 1
        within 'div.pagination' do
          page.should have_link 'Previous'
          page.should have_link '1'
          page.should have_link '2'
          page.should_not have_link '3'
          page.should_not have_link 'Next'
        end

        click_link 'Previous'
        click_link 'Previous'

        within 'div.pagination' do
          page.should_not have_link 'Previous'
          page.should_not have_link '1'
          page.should have_link '2'
          page.should have_link '3'
          page.should have_link 'Next'
        end
      end
    end
  end

  describe 'Show User' do
    it 'should show user details' do
      jeffco = create(
        :customer,
        name: 'Jefferson County',
        equipment_access: true,
        certification_access: false,
        vehicle_access: true
      )

      create(
        :user,
        first_name: 'Judith',
        last_name: 'Jones',
        username: 'judyjones',
        customer: jeffco,
        roles: jeffco.roles
      )

      visit '/'
      page.should have_content 'All Users'
      click_link 'All Users'

      page.should have_content 'All Users'

      click_on 'judyjones'

      page.should have_content 'Show User'

      page.should have_link 'Home'
      page.should have_link 'All Users'

      page.should have_content 'Name'
      page.should have_content 'Username'
      page.should have_content 'Customer'
      page.should have_content 'Email Address'
      page.should have_content 'Expiration Notification Interval'
      page.should have_content 'Equipment Access'
      page.should have_content 'Certification Access'
      page.should have_content 'Vehicle Access'

      page.should have_content 'Jones, Judith'
      page.should have_content 'judyjones'
      page.should have_link 'Jefferson County'
      page.should have_content 'Never'
      page.should have_content /.*Equipment Access.*Yes.*Certification Access.*No.*Vehicle Access.*Yes/
    end
  end

  describe 'Create User' do
    it 'should create new user for specified customer' do
      jeffco = create(
        :customer,
        name: 'Jefferson County',
        equipment_access: true,
        certification_access: false,
        vehicle_access: true
      )

      visit '/'
      click_on 'Jefferson County'

      page.should have_link 'Create New User'
      click_on 'Create New User'

      page.should have_content 'Create User'

      page.should have_link 'Home'
      page.should have_link 'All Users'

      page.should have_content 'Jefferson County'

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
      page.should have_content 'User was successfully created.'

      page.should have_content 'Sandy, Karen'
      page.should have_content 'sandylynn'
      page.should have_link 'Jefferson County'
      page.should have_content 'Daily'
      page.should have_content /.*Equipment Access.*Yes.*Certification Access.*No.*Vehicle Access.*Yes.*/
    end
  end
end