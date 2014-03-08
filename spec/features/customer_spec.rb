require 'spec_helper'

describe 'Customers', slow: true do
  describe 'Create and Show Customer' do
    before do
      login_as_admin
    end

    it 'should create new customer' do
      visit '/'
      click_link 'Create Customer'

      page.should have_content 'Create Customer'
      page.should have_link 'Home'

      page.should have_content 'Name'
      page.should have_content 'Account number'
      page.should have_content 'Equipment access'
      page.should have_content 'Certification access'
      page.should have_content 'Vehicle access'
      page.should have_content 'Contact person'
      page.should have_content 'Contact phone number'
      page.should have_content 'Contact email'
      page.should have_content 'Address1'
      page.should have_content 'Address2'
      page.should have_content 'City'
      page.should have_content 'State'
      page.should have_content 'Zip'

      fill_in 'Name', with: 'Government'
      fill_in 'Account number', with: '123ABC'
      check 'Equipment access'
      check 'Certification access'
      check 'Vehicle access'
      fill_in 'Contact person name', with: 'Joe Blow'
      fill_in 'Contact phone number', with: '(303) 222-3333'
      fill_in 'Contact email', with: 'joe@example.com'
      fill_in 'Address1', with: '300 Main St'
      fill_in 'Address2', with: 'Apt 1'
      fill_in 'City', with: 'Denver'
      select 'Colorado', from: 'State'
      fill_in 'Zip', with: '80222'

      click_on 'Create'

      page.should have_content 'Show Customer'
      page.should have_content "Customer 'Government' was successfully created."

      page.should have_content 'Government'
      page.should have_content '123ABC'
      page.should have_content 'Equipment Access Yes'
      page.should have_content 'Certification Access Yes'
      page.should have_content 'Vehicle Access Yes'
      page.should have_content 'Joe Blow'
      page.should have_content '(303) 222-3333'
      page.should have_content 'joe@example.com'
      page.should have_content '300 Main St'
      page.should have_content 'Apt 1'
      page.should have_content 'Denver'
      page.should have_content 'CO'
      page.should have_content '80222'
    end

    describe 'Show Customer' do
      before do
        create(:location, name: 'Highlands Ranch', customer: government_customer)
        create(:location, name: 'Golden', customer: government_customer)
        create(:location, name: 'Denver', customer: government_customer)
        create(:user, username: 'JS123', first_name: 'Joe', last_name: 'Schmoe', customer: government_customer)
        create(:user, username: 'KG999', first_name: 'Kim', last_name: 'Glow', customer: government_customer)

        create(:customer, name: 'Adams County')
      end

      let(:government_customer) do
        create(
          :customer,
          name: 'Jefferson County',
          account_number: 'ABC123',
          contact_person_name: 'Joe Blow',
          contact_phone_number: '(303) 222-1234',
          contact_email: 'joe@example.com',
          address1: '123 Main St',
          address2: 'Suite 100',
          city: 'Denver',
          state: 'CO',
          zip: '80222',
          equipment_access: true,
          certification_access: true,
          vehicle_access: true
        )
      end

      it 'should show customer`s information' do
        visit customer_path(government_customer)

        page.should have_content 'Show Customer'

        page.should have_link 'Home'
        page.should have_link 'Create Customer'

        page.should have_content 'Jefferson County'
        page.should have_content 'ABC123'
        page.should have_content 'Equipment Access Yes'
        page.should have_content 'Certification Access Yes'
        page.should have_content 'Vehicle Access Yes'
        page.should have_content 'Joe Blow'
        page.should have_content '(303) 222-1234'
        page.should have_content 'joe@example.com'
        page.should have_content '123 Main St'
        page.should have_content 'Suite 100'
        page.should have_content 'Denver'
        page.should have_content 'CO'
        page.should have_content '80222'

        page.should have_content 'Locations'
        page.should have_content 'Denver'
        page.should have_content 'Golden'
        page.should have_content 'Highlands Ranch'

        page.should have_content "Customer's Users"
        within 'table thead tr' do
          page.should have_content 'Username'
          page.should have_content 'First Name'
          page.should have_content 'Last Name'
        end

        within 'table tbody tr:nth-of-type(1)' do
          page.should have_content 'js123'
          page.should have_content 'Joe'
          page.should have_content 'Schmoe'
        end

        within 'table tbody tr:nth-of-type(2)' do
          page.should have_content 'kg999'
          page.should have_content 'Kim'
          page.should have_content 'Glow'
        end

        page.should have_link 'Create New Location'
        click_on 'Create New Location'

        page.should have_content 'Create Location'
        page.should have_content 'Location'
        page.should have_content 'Customer'

        page.should have_select 'location_customer_id'
        page.should have_select 'location_customer_id', options: ['Adams County', 'Jefferson County', 'My Customer']
        page.should have_select 'location_customer_id', selected: 'Jefferson County'

        fill_in 'Location', with: 'Mars'

        click_on 'Create'

        page.should have_content 'Show Location'
        page.should have_content 'Mars'
        page.should have_link 'Jefferson County'

        click_on 'Jefferson County'
        page.should have_content 'Show Customer'
        page.should have_content 'Mars'
      end
    end
  end

  describe 'Customer Reports' do
    let(:admin_customer) do
      create(
        :customer,
        name: 'Jefferson County',
        account_number: 'ABC123',
        contact_person_name: 'Joe',
        contact_email: 'joe@example.com',
        equipment_access: true,
        certification_access: true,
        vehicle_access: true
      )
    end

    before do
      login_as_user_with_role('admin', admin_customer)
    end

    it 'should show All Customers report' do
      create(
        :customer,
        name: 'Adams County',
        account_number: 'AACC',
        contact_person_name: 'Jane',
        contact_email: 'jane@example.com',
        equipment_access: false,
        certification_access: false,
        vehicle_access: false
      )
      create(
        :customer,
        name: 'Douglas County',
        account_number: 'DDD',
        contact_person_name: 'Donna',
        contact_email: 'donna@example.com',
        equipment_access: true,
        certification_access: true,
        vehicle_access: false
      )

      visit '/'
      page.should have_content 'All Customers'
      click_link 'All Customers'

      page.should have_content 'All Customers'
      page.should have_content 'Total: 3'
      page.should have_link 'Home'
      page.should have_link 'Create Customer'

      within 'table thead tr' do
        page.should have_link 'Name'
        page.should have_link 'Account Number'
        page.should have_link 'Contact Person Name'
        page.should have_link 'Contact Email'
        page.should have_content 'Equipment Access'
        page.should have_content 'Certification Access'
        page.should have_content 'Vehicle Access'
      end

      within 'table tbody tr:nth-of-type(1)' do
        page.should have_link 'Adams County'
        page.should have_content 'AACC'
        page.should have_content 'Jane'
        page.should have_content 'jane@example.com'
        page.should have_content 'No'
      end

      within 'table tbody tr:nth-of-type(2)' do
        page.should have_link 'Douglas County'
        page.should have_content 'DDD'
        page.should have_content 'Donna'
        page.should have_content 'donna@example.com'
        page.should have_content 'Yes'
        page.should have_content 'No'
      end

      within 'table tbody tr:nth-of-type(3)' do
        page.should have_link 'Jefferson County'
        page.should have_content 'ABC123'
        page.should have_content 'Joe'
        page.should have_content 'joe@example.com'
        page.should have_content 'Yes'
      end
    end

    context 'sorting' do
      it 'should sort by name' do
        create(:customer, name: 'zeta')
        create(:customer, name: 'beta')
        create(:customer, name: 'alpha')

        visit '/'
        click_link 'All Customers'

        # Ascending search
        click_link 'Name'
        column_data_should_be_in_order('alpha', 'beta', 'Jefferson County', 'zeta')

        # Descending search
        click_link 'Name'
        column_data_should_be_in_order('zeta', 'Jefferson County', 'beta', 'alpha')
      end

      it 'should sort by account number' do
        create(:customer, account_number: '222')
        create(:customer, account_number: '333')
        create(:customer, account_number: '111')

        visit '/'
        click_link 'All Customers'

        # Ascending search
        click_link 'Account Number'
        column_data_should_be_in_order('111', '222', '333', 'ABC123')

        # Descending search
        click_link 'Account Number'
        column_data_should_be_in_order('ABC123', '333', '222', '111')
      end

      it 'should sort by contact_person_name' do
        create(:customer, contact_person_name: 'zeta')
        create(:customer, contact_person_name: 'beta')
        create(:customer, contact_person_name: 'alpha')

        visit '/'
        click_link 'All Customers'

        # Ascending search
        click_link 'Contact Person Name'
        column_data_should_be_in_order('alpha', 'beta', 'Joe', 'zeta')

        # Descending search
        click_link 'Contact Person Name'
        column_data_should_be_in_order('zeta', 'Joe', 'beta', 'alpha')
      end

      it 'should sort by contact_email' do
        create(:customer, contact_email: 'zeta')
        create(:customer, contact_email: 'beta')
        create(:customer, contact_email: 'alpha')

        visit '/'
        click_link 'All Customers'

        # Ascending search
        click_link 'Contact Email'
        column_data_should_be_in_order('alpha', 'beta', 'joe@example.com', 'zeta')

        # Descending search
        click_link 'Contact Email'
        column_data_should_be_in_order('zeta', 'joe@example.com', 'beta', 'alpha')
      end
    end

    context 'pagination' do
      it 'should paginate All Customers report' do
        55.times do
          create(:customer)
        end

        visit '/'
        click_link 'All Customers'

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

  describe 'Manage Customers' do
    before do
      login_as_user_with_role('admin', create(:customer, name: 'Jefferson County'))
    end

    it 'should list customers on home page' do
      visit '/'

      page.should have_link 'Jefferson County'
      click_on 'Jefferson County'

      page.should have_content 'Show Customer'
      page.should have_content 'Jefferson County'
    end
  end
end