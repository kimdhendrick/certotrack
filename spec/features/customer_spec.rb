require 'spec_helper'

describe 'Customers', slow: true do
  before do
    login_as_admin
  end

  describe 'Create Equipment' do
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
  end
end