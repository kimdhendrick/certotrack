require 'spec_helper'

describe 'Certification Type', js: true do

  describe 'Create Equipment' do
    before do
      login_as_certification_user
    end

    it 'should create new units based certification type' do
      visit '/'
      click_link 'Create Certification Type'

      page.should have_content 'Create Certification Type'
      page.should have_link 'Home'

      #Different from CToG, but more consistent, usable:
      #page.should have_link 'Search Certification Types'

      page.should have_content 'Name'
      page.should have_content 'Interval'
      page.should have_content 'Required Units'

      fill_in 'Name', with: 'Periodic Inspection'
      fill_in 'Required Units', with: 32
      select '5 years', from: 'Inspection Interval'


      click_on 'Create'

      page.should have_content 'Show Certification Type'

      page.should have_content 'Name Periodic Inspection'
      page.should have_content 'Required Units 32'
      page.should have_content 'Interval 5 years'
    end
  end
end