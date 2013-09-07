require 'spec_helper'

describe 'Home Page', slow: true do

  context 'when an equipment user' do
    before do
      login_as_equipment_user
    end

    it 'should show all equipment menu links' do
      page.should have_field 'name'
      page.should have_button 'Search'
      page.should have_content 'All Equipment (0)'
      page.should have_content 'Expired Equipment (0)'
      page.should have_content 'Equipment Expiring Soon (0)'
      page.should have_content 'Non-Inspectable Equipment'
      page.should have_content 'Create Equipment'
    end
  end

  context 'when a guest user' do
    before do
      login_as_guest
    end
    it 'should not show any links' do
      page.should have_content 'You are not authorized for any services.  Please contact support@certotrack.com.'

      page.should_not have_content 'All Equipment (0)'
      page.should_not have_content 'Expired Equipment (0)'
      page.should_not have_content 'Equipment Expiring Soon (0)'
      page.should_not have_content 'Non-Inspectable Equipment'
      page.should_not have_content 'Create Equipment'
    end
  end
end