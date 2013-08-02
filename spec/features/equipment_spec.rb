require 'spec_helper'

describe 'Equipment' do

  describe 'All Equipment' do
    context 'when an equipment user' do
      before do
        login_as_equipment_user
      end

      it 'should show all equipment for my customer' do
        create_valid_equipment(name: 'Box 123', customer: @customer)
        create_valid_equipment(name: 'Meter 456', customer: @customer)
        different_customer = create_valid_customer
        create_valid_equipment(name: 'Gauge 987', customer: different_customer)

        click_link 'All Equipment'

        page.should have_content 'Box 123'
        page.should have_content 'Meter 456'
        page.should_not have_content 'Gauge 987'
      end
    end

    context 'when an admin user' do
      before do
        login_as_admin
      end
      it 'should show all equipment for all customers' do
        create_valid_equipment(name: 'Box 123', customer: @customer)
        create_valid_equipment(name: 'Meter 456', customer: @customer)
        create_valid_equipment(name: 'Gauge 987', customer: create_valid_customer)

        click_link 'All Equipment'

        page.should have_content 'Box 123'
        page.should have_content 'Meter 456'
        page.should have_content 'Gauge 987'
      end
    end
  end
end