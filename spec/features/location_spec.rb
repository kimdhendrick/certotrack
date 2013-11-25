require 'spec_helper'

describe 'Locations', slow: true do

  let(:customer) { create(:customer) }

  describe 'All Locations' do
    context 'when an equipment user' do
      before do
        login_as_equipment_user(customer)
        create(:location, name: 'Hawaii', customer: customer)
        create(:location, name: 'Alaska', customer: customer)
      end

      it 'should list all locations' do
        visit root_path

        page.should have_link 'All Locations'
        click_on 'All Locations'

        page.should have_content 'All Locations'

        within 'table thead tr' do
          page.should have_content 'Location'
        end

        within 'table tbody tr:nth-of-type(1)' do
          #page.should have_link 'Alaska'
          page.should have_content 'Alaska'
        end

        within 'table tbody tr:nth-of-type(2)' do
          #page.should have_link 'Hawaii'
          page.should have_content 'Hawaii'
        end
      end
    end

    context 'when an admin user' do
      let(:customer1) { create(:customer) }
      let(:customer2) { create(:customer) }

      before do
        login_as_admin
        create(:location, name: 'Texas', customer: customer1)
        create(:location, name: 'Florida', customer: customer2)
      end

      it 'should show all locations for all customers' do
        click_link 'All Locations'

        page.should have_content 'Customer'
        #page.should have_link 'Customer'

        page.should have_content 'Texas'
        page.should have_content 'Florida'
      end
    end

    context 'sorting' do
      it 'should sort by name' do
        login_as_equipment_user(customer)

        zeta = create(:location, name: 'zeta', customer: customer)
        beta = create(:location, name: 'beta', customer: customer)
        alpha = create(:location, name: 'alpha', customer: customer)

        visit '/'
        click_link 'All Locations'

        # Ascending sort
        click_link 'Location'
        column_data_should_be_in_order('alpha', 'beta', 'zeta')

        # Descending sort
        click_link 'Location'
        column_data_should_be_in_order('zeta', 'beta', 'alpha')
      end

      it 'should sort by customer when admin' do
        login_as_admin
        customer1 = create(:customer, name: 'zeta')
        customer2 = create(:customer, name: 'beta')
        customer3 = create(:customer, name: 'alpha')

        zeta = create(:location, customer: customer1)
        beta = create(:location, customer: customer2)
        alpha = create(:location, customer: customer3)

        visit '/'
        click_link 'All Locations'

        # Ascending sort
        click_link 'Customer'
        column_data_should_be_in_order('alpha', 'beta', 'zeta')

        # Descending sort
        click_link 'Customer'
        column_data_should_be_in_order('zeta', 'beta', 'alpha')
      end
    end

    context 'pagination' do
      before do
        login_as_equipment_user(customer)
      end

      it 'should paginate' do
        55.times do
          create(:location, customer: customer)
        end

        visit '/'
        click_link 'All Locations'

        find 'table.sortable'

        page.all('table tr').count.should == 25 + 1
        within 'div.pagination' do
          page.should_not have_link 'Previous'
          page.should_not have_link '1'
          page.should have_link '2'
          page.should have_link '3'
          page.should have_link 'Next'

          click_link 'Next'
        end


        page.all('table tr').count.should == 25 + 1
        within 'div.pagination' do
          page.should have_link 'Previous'
          page.should have_link '1'
          page.should_not have_link '2'
          page.should have_link '3'
          page.should have_link 'Next'

          click_link 'Next'
        end


        page.all('table tr').count.should == 5 + 1
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
end