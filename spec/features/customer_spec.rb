require 'spec_helper'

describe 'Customers', slow: true do
  before do
    login_as_admin
  end

  describe 'Create and Show Customer' do
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
      end
    end
  end
end