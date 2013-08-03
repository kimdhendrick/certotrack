require 'spec_helper'

describe 'Equipment' do

  describe 'All Equipment' do
    context 'when an equipment user' do
      before do
        login_as_equipment_user
      end

      it 'should show All Equipment report' do
        valid_equipment = create_equipment(
          customer: @customer,
          name: 'Meter',
          serial_number: 'ABC123',
          inspection_interval: 'Annually',
          last_inspection_date: Date.new(2013, 1, 1),
          inspection_type: 'Inspectable',
          expiration_date: Date.new(2024, 2, 3)
        #location
        #assignee
        )

        visit '/'
        page.should have_content 'All Equipment'
        click_link 'All Equipment'

        page.should have_content 'All Equipment List'
        page.should have_content 'Total: 1'
        page.should have_link 'Home'
        page.should have_link 'Create Equipment'

        assert_report_headers_are_correct

        within 'tbody tr', text: 'Meter' do
          page.should have_link 'Meter'
          page.should have_content 'ABC123'
          page.should have_content 'Valid'
          page.should have_content 'Annually'
          page.should have_content '01/01/2013'
          page.should have_content 'Inspectable'
          page.should have_content '02/03/2024'
          #page.should have_content 'location'
          #page.should have_content 'assignee'
        end
      end

      it 'should show Expired Equipment report' do
        expired_equipment = create_equipment(
          customer: @customer,
          name: 'Gauge',
          serial_number: 'XYZ987',
          inspection_interval: 'Monthly',
          last_inspection_date: Date.new(2011, 12, 5),
          inspection_type: 'Inspectable',
          expiration_date: Date.new(2012, 7, 11)
        #location
        #assignee
        )

        visit '/'
        page.should have_content 'Expired Equipment'
        click_link 'Expired Equipment'

        page.should have_content 'Expired Equipment List'
        page.should have_content 'Total: 1'
        page.should have_link 'Home'
        page.should have_link 'Create Equipment'

        assert_report_headers_are_correct

        within 'tbody tr', text: 'Gauge' do
          page.should have_link 'Gauge'
          page.should have_content 'XYZ987'
          page.should have_content 'Expired'
          page.should have_content 'Monthly'
          page.should have_content '12/05/2011'
          page.should have_content 'Inspectable'
          page.should have_content '07/11/2012'
          #page.should have_content 'location'
          #page.should have_content 'assignee'
        end
      end
    end

    context 'when an admin user' do
      before do
        login_as_admin
      end

      it 'should show all equipment for all customers' do
        create_equipment(name: 'Box 123', customer: @customer)
        create_equipment(name: 'Meter 456', customer: @customer)
        create_equipment(name: 'Gauge 987', customer: create_customer)

        click_link 'All Equipment'

        page.should have_content 'Box 123'
        page.should have_content 'Meter 456'
        page.should have_content 'Gauge 987'
      end
    end
  end

  def assert_report_headers_are_correct
    within 'thead tr' do
      page.should have_content 'Name'
      page.should have_content 'Serial Number'
      page.should have_content 'Status'
      page.should have_content 'Inspection Interval'
      page.should have_content 'Last Inspection Date'
      page.should have_content 'Type'
      page.should have_content 'Expiration Date'
      page.should have_content 'Assignee'
    end
  end

end