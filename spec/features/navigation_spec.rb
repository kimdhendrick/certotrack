require 'spec_helper'

describe 'Navigation' do

  describe 'Home page links' do
    before do
      login_as_equipment_user
    end

    it 'should navigate Home page' do
      visit root_path
      page.should have_content 'Welcome to Certotrack'

      click_link 'All Equipment'
      page.should have_content 'All Equipment List'

      visit root_path
      click_link 'Create Equipment'
      page.should have_content 'Create Equipment'
    end

    it 'should navigate All Equipment List' do
      visit equipment_index_url
      page.should have_content 'All Equipment List'

      click_link 'Home'
      page.should have_content 'Welcome to Certotrack'

      visit equipment_index_url
      click_link 'Create Equipment'
      page.should have_content 'Create Equipment'
    end

    it 'should navigate Expired Equipment List' do
      visit expired_equipment_url
      page.should have_content 'Expired Equipment List'

      click_link 'Home'
      page.should have_content 'Welcome to Certotrack'

      visit expired_equipment_url
      click_link 'Create Equipment'
      page.should have_content 'Create Equipment'
    end

    it 'should navigate Create Equipment' do
      visit new_equipment_url
      page.should have_content 'Create Equipment'

      click_link 'Home'
      page.should have_content 'Welcome to Certotrack'
    end
  end
end