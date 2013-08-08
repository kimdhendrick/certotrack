require 'spec_helper'

describe 'Navigation', js:true do

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
      visit equipment_index_path
      page.should have_content 'All Equipment List'

      click_link 'Home'
      page.should have_content 'Welcome to Certotrack'

      visit equipment_index_path
      click_link 'Create Equipment'
      page.should have_content 'Create Equipment'
    end

    it 'should navigate Expired Equipment List' do
      visit expired_equipment_path
      page.should have_content 'Expired Equipment List'

      click_link 'Home'
      page.should have_content 'Welcome to Certotrack'

      visit expired_equipment_path
      click_link 'Create Equipment'
      page.should have_content 'Create Equipment'
    end

    it 'should navigate Expiring Equipment List' do
      visit expiring_equipment_path
      page.should have_content 'Expiring Equipment List'

      click_link 'Home'
      page.should have_content 'Welcome to Certotrack'

      visit expiring_equipment_path
      click_link 'Create Equipment'
      page.should have_content 'Create Equipment'
    end

    it 'should navigate Non-Inspectable Equipment List' do
      visit noninspectable_equipment_path
      page.should have_content 'Non-Inspectable Equipment List'

      click_link 'Home'
      page.should have_content 'Welcome to Certotrack'

      visit noninspectable_equipment_path
      click_link 'Create Equipment'
      page.should have_content 'Create Equipment'
    end

    it 'should navigate Create Equipment' do
      visit new_equipment_path
      page.should have_content 'Create Equipment'

      click_link 'Home'
      page.should have_content 'Welcome to Certotrack'
    end
  end
end