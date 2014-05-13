require 'spec_helper'

describe 'Equipment', slow: true do
  let(:customer) { create(:customer) }

  describe 'Show Equipment' do
    let!(:denver_location) { create(:location, name: 'Denver', customer_id: customer.id) }

    let!(:current_user) { login_as_equipment_user(customer) }

    it 'should render equipment show page' do
      valid_equipment = create(:equipment,
                               customer: customer,
                               name: 'Meter',
                               serial_number: 'ABC123',
                               inspection_interval: 'Annually',
                               last_inspection_date: Date.new(2013, 1, 1),
                               expiration_date: Date.new(2024, 2, 3),
                               comments: 'my notes',
                               location_id: denver_location.id
      )

      visit dashboard_path
      click_link 'All Equipment'
      click_link 'Meter'

      page.should have_content 'Show Equipment'
      page.should have_link 'Home'
      page.should have_link 'All Equipment'
      page.should have_link 'Create Equipment'

      page.should have_content 'Name'
      page.should have_content 'Serial Number'
      page.should have_content 'Status'
      page.should have_content 'Location'
      page.should have_content 'Inspection Interval'
      page.should have_content 'Last Inspection Date'
      page.should have_content 'Expiration Date'
      page.should have_content 'Comments'

      page.should have_content 'Meter'
      page.should have_content 'ABC123'
      page.should have_content 'Denver'
      page.should have_content 'Valid'
      page.should have_content 'Annually'
      page.should have_content '01/01/2013'
      page.should have_content '02/03/2024'
      page.should have_content 'my notes'

      page.should have_link 'Edit'
      page.should have_link 'Delete'
    end
  end

  describe 'Create Equipment' do
    let!(:denver_location) { create(:location, name: 'Denver', customer_id: customer.id) }
    let!(:littleton_location) { create(:location, name: 'Littleton', customer_id: customer.id) }
    let!(:alpha_first_employee) { create(:employee, first_name: 'Alpha', last_name: 'Alpha', customer_id: customer.id) }
    let!(:special_employee) { create(:employee, first_name: 'Special', last_name: 'Employee', customer_id: customer.id) }
    let!(:alpha_last_employee) { create(:employee, first_name: 'Zeta', last_name: 'Zeta', customer_id: customer.id) }

    before do
      login_as_equipment_user(customer)
    end

    it 'should create new equipment assigned to a location', js: true do
      visit dashboard_path
      click_link 'Create Equipment'

      page.should have_content 'Create Equipment'
      page.should have_link 'Home'

      page.should have_content 'Name'
      page.should have_content 'Serial Number'
      page.should have_content 'Assignee'
      page.should have_content 'Inspection Interval'
      page.should have_content 'Last Inspection Date'
      page.should have_content 'Comments'

      fill_in 'Name', with: 'Level'
      fill_in 'Serial Number', with: '765-CKD'
      select 'Location', from: 'Assignee'
      find '#assignedTo'
      page.should have_select(
                    'assignedTo',
                    :options => ['Denver', 'Littleton']
                  )
      select 'Littleton', from: 'assignedTo'
      select '5 years', from: 'Inspection Interval'
      fill_in 'Last Inspection Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Equipment'
      page.should have_content "Equipment 'Level' was successfully created."

      page.should have_content 'Level'
      page.should have_content '765-CKD'
      page.should have_content 'Littleton'
      page.should have_content 'Expired'
      page.should have_content '5 years'
      page.should have_content '01/01/2000'
      page.should have_content '01/01/2005'
      page.should have_content 'Special Notes'
    end

    it 'should create new equipment assigned to an employee', js: true do
      visit dashboard_path
      click_link 'Create Equipment'

      page.should have_content 'Create Equipment'
      page.should have_link 'Home'
      page.should have_link 'Search Equipment'

      page.should have_content 'Name'
      page.should have_content 'Serial Number'
      page.should have_content 'Assignee'
      page.should have_content 'Inspection Interval'
      page.should have_content 'Last Inspection Date'
      page.should have_content 'Comments'

      fill_in 'Name', with: 'Level'
      fill_in 'Serial Number', with: '765-CKD'
      select 'Employee', from: 'Assignee'
      find '#assignedTo'
      page.should have_select(
                    'assignedTo',
                    :options => ['Alpha, Alpha', 'Employee, Special', 'Zeta, Zeta']
                  )

      select 'Employee, Special', from: 'assignedTo'
      select '5 years', from: 'Inspection Interval'
      fill_in 'Last Inspection Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Equipment'
      page.should have_content "Equipment 'Level' was successfully created."

      page.should have_content 'Level'
      page.should have_content '765-CKD'
      page.should have_content 'Employee, Special'
      page.should have_content 'Expired'
      page.should have_content '5 years'
      page.should have_content '01/01/2000'
      page.should have_content '01/01/2005'
      page.should have_content 'Special Notes'
    end

    it 'should create new unassigned equipment' do
      visit dashboard_path
      click_link 'Create Equipment'

      page.should have_content 'Create Equipment'
      page.should have_link 'Home'

      page.should have_content 'Name'
      page.should have_content 'Serial Number'
      page.should have_content 'Assignee'
      page.should have_content 'Inspection Interval'
      page.should have_content 'Last Inspection Date'
      page.should have_content 'Comments'

      fill_in 'Name', with: 'Level'
      fill_in 'Serial Number', with: '765-CKD'
      select '5 years', from: 'Inspection Interval'
      fill_in 'Last Inspection Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Create'

      page.should have_content 'Show Equipment'
      page.should have_content "Equipment 'Level' was successfully created."

      page.should have_content 'Level'
      page.should have_content '765-CKD'
      page.should have_content 'Unassigned'
      page.should have_content 'Expired'
      page.should have_content '5 years'
      page.should have_content '01/01/2000'
      page.should have_content '01/01/2005'
      page.should have_content 'Special Notes'
    end

    it 'should alert on future dates', js: true do
      visit dashboard_path
      click_link 'Create Equipment'

      fill_in 'Name', with: 'Level'
      fill_in 'Serial Number', with: '765-CKD-123'
      fill_in 'Last Inspection Date', with: '01/01/2055'

      click_on 'Create'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to enter a future date?')
      alert.dismiss

      fill_in 'Last Inspection Date', with: '01/01/2000'

      click_on 'Create'

      page.should have_content 'Show Equipment'
      page.should have_content '01/01/2000'

      visit dashboard_path
      click_link 'Create Equipment'

      fill_in 'Name', with: 'Level'
      fill_in 'Serial Number', with: '765-CKD-456'
      fill_in 'Last Inspection Date', with: '01/01/2055'

      click_on 'Create'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to enter a future date?')
      alert.accept

      page.should have_content 'Show Equipment'
      page.should have_content "Equipment 'Level' was successfully created."
      page.should have_content '01/01/2055'
    end

    it 'should auto complete on name', js: true do
      create(:equipment, name: 'Leveler', customer: customer)

      visit dashboard_path
      click_link 'Create Equipment'

      assert_autocomplete('equipment_name', 'lev', 'Leveler')

      fill_in 'Serial Number', with: '765-CKD'
      select 'Not Required', from: 'Inspection Interval'

      click_on 'Create'

      page.should have_content 'Show Equipment'
      page.should have_content 'Leveler'
    end
  end

  describe 'Update Equipment' do
    let!(:denver_location) { create(:location, name: 'Denver', customer_id: customer.id) }
    let!(:littleton_location) { create(:location, name: 'Littleton', customer_id: customer.id) }
    let!(:special_employee) { create(:employee, first_name: 'Special', last_name: 'Employee', customer_id: customer.id) }

    before do
      login_as_equipment_user(customer)
    end

    it 'should update existing equipment', js: true do
      valid_equipment = create(:equipment,
                               customer: customer,
                               name: 'Meter',
                               serial_number: 'ABC123',
                               inspection_interval: 'Annually',
                               last_inspection_date: Date.new(2013, 1, 1),
                               expiration_date: Date.new(2024, 2, 3),
                               comments: 'my notes',
                               location_id: littleton_location.id
      )

      visit dashboard_path
      click_link 'All Equipment'
      click_link 'Meter'

      page.should have_content 'Show Equipment'
      click_on 'Edit'

      page.should have_content 'Edit Equipment'
      page.should have_link 'Home'
      page.should have_link 'All Equipment'
      page.should have_link 'Create Equipment'

      page.should have_content 'Name'
      page.should have_content 'Serial Number'
      page.should have_content 'Assignee'
      page.should have_content 'Location'
      page.should have_content 'Inspection Interval'
      page.should have_content 'Last Inspection Date'
      page.should have_content 'Comments'

      page.should have_link 'Delete'

      fill_in 'Name', with: 'Level'
      fill_in 'Serial Number', with: '765-CKD'

      select 'Employee', from: 'Assignee'
      find '#assignedTo'
      select 'Employee, Special', from: 'assignedTo'
      select '5 years', from: 'Inspection Interval'
      fill_in 'Last Inspection Date', with: '01/01/2000'
      fill_in 'Comments', with: 'Special Notes'

      click_on 'Update'

      page.should have_content 'Show Equipment'
      page.should have_content "Equipment 'Level' was successfully updated."

      page.should have_content 'Level'
      page.should have_content '765-CKD'
      page.should have_content 'Employee, Special'
      page.should have_content 'Expired'
      page.should have_content '5 years'
      page.should have_content '01/01/2000'
      page.should have_content '01/01/2005'
      page.should have_content 'Special Notes'
    end

    it 'should alert on future dates', js: true do
      valid_equipment = create(:equipment,
                               customer: customer,
                               name: 'Meter',
                               serial_number: 'ABC123',
                               inspection_interval: 'Annually',
                               last_inspection_date: Date.new(2013, 1, 1),
                               expiration_date: Date.new(2024, 2, 3),
                               comments: 'my notes',
                               location_id: littleton_location.id
      )

      visit dashboard_path
      click_link 'All Equipment'
      click_link 'Meter'
      click_on 'Edit'

      fill_in 'Last Inspection Date', with: '01/01/2055'

      click_on 'Update'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to enter a future date?')
      alert.dismiss

      fill_in 'Last Inspection Date', with: '01/01/2000'

      click_on 'Update'

      page.should have_content 'Show Equipment'
      page.should have_content '01/01/2000'

      visit dashboard_path
      click_link 'All Equipment'
      click_link 'Meter'
      click_link 'Edit'

      fill_in 'Last Inspection Date', with: '01/01/2055'

      click_on 'Update'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to enter a future date?')
      alert.accept

      page.should have_content 'Show Equipment'
      page.should have_content "Equipment 'Meter' was successfully updated."
      page.should have_content '01/01/2055'
    end
  end

  describe 'Delete Equipment' do
    let!(:denver_location) { create(:location, name: 'Denver', customer_id: customer.id) }

    before do
      login_as_equipment_user(customer)
    end

    it 'should delete existing equipment', js: true do
      valid_equipment = create(:equipment,
                               customer: customer,
                               name: 'Meter'
      )

      visit dashboard_path
      click_link 'All Equipment'
      click_link 'Meter'

      page.should have_content 'Show Equipment'
      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this equipment?')
      alert.dismiss

      page.should have_content 'Show Equipment'

      click_on 'Delete'

      alert = page.driver.browser.switch_to.alert
      alert.text.should eq('Are you sure you want to delete this equipment?')
      alert.accept

      page.should have_content 'All Equipment'
      page.should have_content "Equipment 'Meter' was successfully deleted."
    end
  end

  describe 'Reports' do
    context 'when an equipment user' do
      let!(:denver_location) { create(:location, name: 'Denver', customer_id: customer.id) }
      let!(:littleton_location) { create(:location, name: 'Littleton', customer_id: customer.id) }
      let!(:special_employee) { create(:employee, first_name: 'Special', last_name: 'Employee', customer_id: customer.id) }

      let!(:current_user) { login_as_equipment_user(customer) }

      context 'All Equipment report' do
        before do
          create(:equipment,
                 customer: customer,
                 name: 'Meter',
                 serial_number: 'ABC123',
                 inspection_interval: 'Annually',
                 last_inspection_date: Date.new(2013, 1, 1),
                 expiration_date: Date.new(2024, 2, 3),
                 employee_id: special_employee.id
          )

          create(:equipment,
                 customer: customer,
                 name: 'Box',
                 serial_number: 'BBB999',
                 inspection_interval: 'Annually',
                 last_inspection_date: Date.new(2012, 1, 1),
                 expiration_date: Date.new(2013, 1, 1),
                 location_id: denver_location.id
          )
        end

        it 'should show All Equipment report' do
          visit dashboard_path
          page.should have_content 'All Equipment'
          click_link 'All Equipment'

          page.should have_content 'All Equipment'
          page.should have_content 'Total: 2'
          page.should have_link 'Home'
          page.should have_link 'Create Equipment'

          _assert_report_headers_are_correct

          within 'table tbody tr:nth-of-type(1)' do
            page.should have_link 'Box'
            page.should have_content 'BBB999'
            page.should have_content 'Expired'
            page.should have_content 'Annually'
            page.should have_content '01/01/2012'
            page.should have_content 'Inspectable'
            page.should have_content '01/01/2013'
            page.should have_content 'Denver'
          end

          within 'table tbody tr:nth-of-type(2)' do
            page.should have_link 'Meter'
            page.should have_content 'ABC123'
            page.should have_content 'Valid'
            page.should have_content 'Annually'
            page.should have_content '01/01/2013'
            page.should have_content 'Inspectable'
            page.should have_content '02/03/2024'
            page.should have_content 'Employee, Special'
          end
        end

        it 'should export to CSV' do
          visit dashboard_path
          click_link 'All Equipment'

          click_on 'Export to CSV'

          page.response_headers['Content-Type'].should include 'text/csv'
          header_row = 'Name,Serial Number,Status,Inspection Interval,Last Inspection Date,Inspection Type,Expiration Date,Assignee,Created By User,Created Date'
          page.text.should == "#{header_row} Meter,ABC123,Valid,Annually,01/01/2013,Inspectable,02/03/2024,\"Employee, Special\",username,#{Date.current.strftime("%m/%d/%Y")} Box,BBB999,Expired,Annually,01/01/2012,Inspectable,01/01/2013,Denver,username,#{Date.current.strftime("%m/%d/%Y")}"
        end

        it 'should export to PDF' do
          visit dashboard_path
          click_link 'All Equipment'

          click_on 'Export to PDF'

          page.response_headers['Content-Type'].should include 'pdf'
        end

        it 'should export to Excel' do
          visit dashboard_path
          click_link 'All Equipment'

          click_on 'Export to Excel'

          page.response_headers['Content-Type'].should include 'excel'
        end
      end

      context 'Expired Equipment report' do
        before do
          expired_equipment = create(:equipment,
                                     customer: customer,
                                     name: 'Gauge',
                                     serial_number: 'XYZ987',
                                     inspection_interval: Interval::ONE_MONTH.text,
                                     last_inspection_date: Date.new(2011, 12, 5),
                                     expiration_date: Date.new(2012, 7, 11),
                                     location_id: littleton_location.id
          )
        end

        it 'should show Expired Equipment report' do
          visit dashboard_path
          page.should have_content 'Expired Equipment'
          click_link 'Expired Equipment'

          page.should have_content 'Expired Equipment List'
          page.should have_content 'Total: 1'
          page.should have_link 'Home'
          page.should have_link 'Create Equipment'

          _assert_report_headers_are_correct

          within 'tbody tr', text: 'Gauge' do
            page.should have_link 'Gauge'
            page.should have_content 'XYZ987'
            page.should have_content 'Expired'
            page.should have_content '1 month'
            page.should have_content '12/05/2011'
            page.should have_content 'Inspectable'
            page.should have_content '07/11/2012'
            page.should have_content 'Littleton'
          end
        end

        it 'should export to CSV' do
          visit dashboard_path
          click_link 'Expired Equipment'

          click_on 'Export to CSV'

          page.response_headers['Content-Type'].should include 'text/csv'
          header_row = 'Name,Serial Number,Status,Inspection Interval,Last Inspection Date,Inspection Type,Expiration Date,Assignee,Created By User,Created Date'
          page.text.should == "#{header_row} Gauge,XYZ987,Expired,1 month,12/05/2011,Inspectable,07/11/2012,Littleton,username,#{Date.current.strftime("%m/%d/%Y")}"
        end

        it 'should export to Excel' do
          visit dashboard_path
          click_link 'Expired Equipment'

          click_on 'Export to Excel'

          page.response_headers['Content-Type'].should include 'excel'
        end

        it 'should export to PDF' do
          visit dashboard_path
          click_link 'Expired Equipment'

          click_on 'Export to PDF'

          page.response_headers['Content-Type'].should include 'pdf'
        end
      end

      context 'Expiring Equipment report' do
        before do
          expiring_equipment = create(:equipment,
                                      customer: customer,
                                      name: 'Banana',
                                      serial_number: 'BANA',
                                      inspection_interval: Interval::ONE_MONTH.text,
                                      last_inspection_date: Date.new(2014, 3, 15),
                                      expiration_date: Date.tomorrow,
                                      location_id: denver_location.id
          )
        end

        it 'should show Expiring Equipment report' do
          visit dashboard_path
          page.should have_content 'Equipment Expiring Soon'
          click_link 'Equipment Expiring Soon'

          page.should have_content 'Expiring Equipment List'
          page.should have_content 'Total: 1'
          page.should have_link 'Home'
          page.should have_link 'Create Equipment'

          _assert_report_headers_are_correct

          within 'tbody tr', text: 'Banana' do
            page.should have_link 'Banana'
            page.should have_content 'BANA'
            page.should have_content 'Warning'
            page.should have_content '1 month'
            page.should have_content 'Inspectable'
            page.should have_content 'Denver'
          end
        end

        it 'should export to CSV' do
          visit dashboard_path
          click_link 'Equipment Expiring Soon'

          click_on 'Export to CSV'

          page.response_headers['Content-Type'].should include 'text/csv'
          header_row = 'Name,Serial Number,Status,Inspection Interval,Last Inspection Date,Inspection Type,Expiration Date,Assignee,Created By User,Created Date'
          page.text.should == "#{header_row} Banana,BANA,Warning,1 month,03/15/2014,Inspectable,#{Date.tomorrow.strftime("%m/%d/%Y")},Denver,username,#{Date.current.strftime("%m/%d/%Y")}"
        end

        it 'should export to Excel' do
          visit dashboard_path
          click_link 'Equipment Expiring Soon'

          click_on 'Export to Excel'

          page.response_headers['Content-Type'].should include 'excel'
        end

        it 'should export to PDF' do
          visit dashboard_path
          click_link 'Equipment Expiring Soon'

          click_on 'Export to PDF'

          page.response_headers['Content-Type'].should include 'pdf'
        end
      end

      context 'Non-Inspectable Equipment report' do
        before do
          non_inspectable_equipment = create(:equipment,
                                             customer: customer,
                                             name: 'MDC',
                                             serial_number: 'mdc1',
                                             inspection_interval: Interval::NOT_REQUIRED.text,
                                             location_id: denver_location.id
          )
        end
        it 'should show Non-Inspectable Equipment report' do
          visit dashboard_path
          page.should have_content 'Non-Inspectable Equipment'
          click_link 'Non-Inspectable Equipment'

          page.should have_content 'Non-Inspectable Equipment List'
          page.should have_content 'Total: 1'
          page.should have_link 'Home'
          page.should have_link 'Create Equipment'

          _assert_report_headers_are_correct

          within 'tbody tr', text: 'MDC' do
            page.should have_link 'MDC'
            page.should have_content 'mdc1'
            page.should have_content 'Not Required'
            page.should have_content 'Inspectable'
            page.should have_content 'Denver'
          end
        end

        it 'should export to CSV' do
          visit dashboard_path
          click_link 'Non-Inspectable Equipment'

          click_on 'Export to CSV'

          page.response_headers['Content-Type'].should include 'text/csv'
          header_row = 'Name,Serial Number,Status,Inspection Interval,Last Inspection Date,Inspection Type,Expiration Date,Assignee,Created By User,Created Date'
          page.text.should == "#{header_row} MDC,mdc1,N/A,Not Required,01/01/2000,Non-Inspectable,\"\",Denver,username,#{Date.current.strftime("%m/%d/%Y")}"
        end

        it 'should export to Excel' do
          visit dashboard_path
          click_link 'Non-Inspectable Equipment'

          click_on 'Export to Excel'

          page.response_headers['Content-Type'].should include 'excel'
        end

        it 'should export to PDF' do
          visit dashboard_path
          click_link 'Non-Inspectable Equipment'

          click_on 'Export to PDF'

          page.response_headers['Content-Type'].should include 'pdf'
        end
      end
    end

    context 'when an admin user' do
      before do
        login_as_admin
      end

      it 'should show all equipment for all customers' do
        create(:equipment, name: 'Box 123', customer: customer)
        create(:equipment, name: 'Meter 456', customer: customer)
        create(:equipment, name: 'Gauge 987')

        click_link 'All Equipment'

        page.should have_content 'Box 123'
        page.should have_content 'Meter 456'
        page.should have_content 'Gauge 987'
      end
    end

    context 'sorting' do
      before do
        login_as_equipment_user(customer)
      end

      it 'should sort by name' do
        create(:equipment, name: 'zeta', customer: customer)
        create(:equipment, name: 'beta', customer: customer)
        create(:equipment, name: 'alpha', customer: customer)

        visit dashboard_path
        click_link 'All Equipment'

        # Ascending sort
        click_link 'Name'
        column_data_should_be_in_order('alpha', 'beta', 'zeta')

        # Descending sort
        click_link 'Name'
        column_data_should_be_in_order('zeta', 'beta', 'alpha')
      end

      it 'should sort by serial number' do
        create(:equipment, serial_number: '222', customer: customer)
        create(:equipment, serial_number: '333', customer: customer)
        create(:equipment, serial_number: '111', customer: customer)

        visit dashboard_path
        click_link 'All Equipment'

        click_link 'Serial Number'
        column_data_should_be_in_order('111', '222', '333')

        click_link 'Serial Number'
        column_data_should_be_in_order('333', '222', '111')
      end

      it 'should sort by status' do
        create(:expiring_equipment, customer: customer)
        create(:expired_equipment, customer: customer)
        create(:valid_equipment, customer: customer)

        visit dashboard_path
        click_link 'All Equipment'

        click_link 'Status'
        column_data_should_be_in_order(Status::VALID.text, Status::EXPIRING.text, Status::EXPIRED.text)

        click_link 'Status'
        column_data_should_be_in_order(Status::EXPIRED.text, Status::EXPIRING.text, Status::VALID.text)
      end

      it 'should sort by inspection interval' do
        create(:equipment, inspection_interval: Interval::SIX_MONTHS.text, customer: customer)
        create(:equipment, inspection_interval: Interval::TWO_YEARS.text, customer: customer)
        create(:equipment, inspection_interval: Interval::ONE_YEAR.text, customer: customer)
        create(:equipment, inspection_interval: Interval::FIVE_YEARS.text, customer: customer)
        create(:equipment, inspection_interval: Interval::NOT_REQUIRED.text, customer: customer)
        create(:equipment, inspection_interval: Interval::THREE_YEARS.text, customer: customer)
        create(:equipment, inspection_interval: Interval::ONE_MONTH.text, customer: customer)
        create(:equipment, inspection_interval: Interval::THREE_MONTHS.text, customer: customer)

        visit dashboard_path
        click_link 'All Equipment'

        click_link 'Inspection Interval'
        column_data_should_be_in_order(
          Interval::ONE_MONTH.text,
          Interval::THREE_MONTHS.text,
          Interval::SIX_MONTHS.text,
          Interval::ONE_YEAR.text,
          Interval::TWO_YEARS.text,
          Interval::THREE_YEARS.text,
          Interval::FIVE_YEARS.text,
          Interval::NOT_REQUIRED.text
        )

        click_link 'Inspection Interval'
        column_data_should_be_in_order(
          Interval::NOT_REQUIRED.text,
          Interval::FIVE_YEARS.text,
          Interval::THREE_YEARS.text,
          Interval::TWO_YEARS.text,
          Interval::ONE_YEAR.text,
          Interval::SIX_MONTHS.text,
          Interval::THREE_MONTHS.text,
          Interval::ONE_MONTH.text
        )
      end

      it 'should sort by last inspection date' do
        earliest_date = Date.new(2013, 12, 1)
        middle_date = Date.new(2013, 12, 20)
        latest_date = Date.new(2014, 1, 1)

        create(:equipment, last_inspection_date: middle_date, customer: customer)
        create(:equipment, last_inspection_date: latest_date, customer: customer)
        create(:equipment, last_inspection_date: earliest_date, customer: customer)

        visit dashboard_path
        click_link 'All Equipment'

        click_link 'Last Inspection Date'
        column_data_should_be_in_order(DateHelpers.date_to_string(earliest_date), DateHelpers.date_to_string(middle_date), DateHelpers.date_to_string(latest_date))

        click_link 'Last Inspection Date'
        column_data_should_be_in_order(DateHelpers.date_to_string(latest_date), DateHelpers.date_to_string(middle_date), DateHelpers.date_to_string(earliest_date))
      end

      it 'should sort by inspection type' do
        inspectable1 = create(:equipment, inspection_interval: Interval::ONE_YEAR.text, customer: customer)
        not_inspectable = create(:equipment, inspection_interval: Interval::NOT_REQUIRED.text, customer: customer)
        inspectable2 = create(:equipment, inspection_interval: Interval::FIVE_YEARS.text, customer: customer)

        visit dashboard_path
        click_link 'All Equipment'

        click_link 'Inspection Type'
        column_data_should_be_in_order("Inspectable", "Inspectable", "Non-Inspectable")

        click_link 'Inspection Type'
        column_data_should_be_in_order("Non-Inspectable", "Inspectable", "Inspectable")
      end

      it 'should sort by expiration date' do
        earliest_date = Date.new(2013, 12, 1)
        middle_date = Date.new(2013, 12, 20)
        latest_date = Date.new(2014, 1, 1)

        create(:equipment, expiration_date: middle_date, customer: customer)
        create(:equipment, expiration_date: latest_date, customer: customer)
        create(:equipment, expiration_date: earliest_date, customer: customer)
        create(:equipment, expiration_date: nil, customer: customer)

        visit dashboard_path
        click_link 'All Equipment'

        click_link 'Expiration Date'
        column_data_should_be_in_order(DateHelpers.date_to_string(earliest_date), DateHelpers.date_to_string(middle_date), DateHelpers.date_to_string(latest_date), '')

        click_link 'Expiration Date'
        column_data_should_be_in_order('', DateHelpers.date_to_string(latest_date), DateHelpers.date_to_string(middle_date), DateHelpers.date_to_string(earliest_date))
      end

      it 'should sort by assignee' do
        middle_employee = create(:employee, first_name: 'Bob', last_name: 'Baker')
        first_employee = create(:employee, first_name: 'Albert', last_name: 'Alfonso')
        last_employee = create(:employee, first_name: 'Zoe', last_name: 'Zephyr')

        first_location = create(:location, name: 'Alcatraz')
        last_location = create(:location, name: 'Zurich')
        middle_location = create(:location, name: 'Burbank')

        create(:equipment, employee: middle_employee, customer: customer)
        create(:equipment, location: last_location, customer: customer)
        create(:equipment, location: first_location, customer: customer)
        create(:equipment, employee: last_employee, customer: customer)
        create(:equipment, employee: first_employee, customer: customer)
        create(:equipment, location: middle_location, customer: customer)

        visit dashboard_path
        click_link 'All Equipment'

        click_link 'Assignee'
        column_data_should_be_in_order('Alcatraz', 'Alfonso, Albert', 'Baker, Bob', 'Burbank', 'Zephyr, Zoe', 'Zurich')

        click_link 'Assignee'
        column_data_should_be_in_order('Zurich', 'Zephyr, Zoe', 'Burbank', 'Baker, Bob', 'Alfonso, Albert', 'Alcatraz')
      end
    end

    context 'pagination' do
      before do
        login_as_equipment_user(customer)
      end

      it 'should paginate All Equipment report' do
        55.times do
          create(:equipment, customer: customer)
        end

        visit dashboard_path
        click_link 'All Equipment'

        find 'table.sortable'

        page.all('table tr').count.should == 25 + 1
        click_link 'Next'

        page.all('table tr').count.should == 25 + 1

        click_link 'Next'

        page.all('table tr').count.should == 5 + 1

        click_link 'Previous'
        click_link 'Previous'
      end
    end
  end

  describe 'Search' do
    context 'when an equipment user' do
      let!(:current_user) { login_as_equipment_user(customer) }

      context 'Search Equipment page' do
        before do
          create(:equipment,
                 customer: customer,
                 name: 'Unique Name',
                 serial_number: 'UniqueSN'
          )

          create(:equipment,
                 customer: customer,
                 name: 'Box',
                 serial_number: 'BoxSN'
          )
        end

        it 'should show Search Equipment page' do
          visit dashboard_path

          within '[data-equipment-search-form]' do
            click_on 'Search'
          end

          page.should have_content 'Search Equipment'
          page.should have_link 'Home'
          page.should have_link 'Create Equipment'

          fill_in 'Name contains:', with: 'Unique'

          click_on 'Search'

          page.should have_content 'Search Equipment'

          _assert_report_headers_are_correct

          find 'table.sortable'

          page.should have_link 'Unique Name'
          page.should_not have_link 'Box'
        end

        it 'should export to CSV' do
          visit dashboard_path

          within '[data-equipment-search-form]' do
            click_on 'Search'
          end

          fill_in 'Name contains:', with: 'Unique'
          click_on 'Search'

          click_on 'Export to CSV'

          page.response_headers['Content-Type'].should include 'text/csv'
          header_row = 'Name,Serial Number,Status,Inspection Interval,Last Inspection Date,Inspection Type,Expiration Date,Assignee,Created By User,Created Date'
          page.text.should == "#{header_row} Unique Name,UniqueSN,N/A,Annually,01/01/2000,Inspectable,\"\",Unassigned,username,#{Date.current.strftime("%m/%d/%Y")}"
        end

        it 'should export to Excel' do
          visit dashboard_path

          within '[data-equipment-search-form]' do
            click_on 'Search'
          end

          click_on 'Export to Excel'

          page.response_headers['Content-Type'].should include 'excel'
        end

        it 'should export to PDF' do
          visit dashboard_path

          within '[data-equipment-search-form]' do
            click_on 'Search'
          end

          click_on 'Export to PDF'

          page.response_headers['Content-Type'].should include 'pdf'
        end
      end

      it 'should show Search Equipment box', js: true do
        create(:equipment,
               customer: customer,
               name: 'Unique Name'
        )

        create(:equipment,
               customer: customer,
               name: 'Box'
        )

        visit dashboard_path

        assert_autocomplete('name', 'bo', 'Box')

        within '[data-equipment-search-form]' do
          fill_in 'name', with: 'Unique'
          click_on 'Search'
        end

        page.should have_content 'Search Equipment'

        _assert_report_headers_are_correct

        find 'table.sortable'

        find_field('name').value.should eq 'Unique'
        page.should have_link 'Unique Name'
        page.should_not have_link 'Box'
      end

      it 'should search and sort simultaneously' do
        create(:equipment,
               customer: customer,
               name: 'Unique Name'
        )

        create(:equipment,
               customer: customer,
               name: 'Box'
        )

        visit dashboard_path
        within '[data-equipment-search-form]' do
          click_on 'Search'
        end

        page.should have_content 'Search Equipment'
        page.should have_link 'Home'
        page.should have_link 'Create Equipment'

        fill_in 'Name contains:', with: 'Unique'

        click_on 'Search'

        page.should have_content 'Search Equipment'

        _assert_report_headers_are_correct

        find 'table.sortable'

        page.should have_link 'Unique Name'
        page.should_not have_link 'Box'

        click_on 'Name'

        page.should have_link 'Unique Name'
        page.should_not have_link 'Box'
      end

      it 'should auto complete on name', js: true do
        create(:equipment, name: 'Leveler', customer: customer)

        visit dashboard_path
        click_on 'Search'

        assert_autocomplete('name', 'lev', 'Leveler')
      end

    end
  end

  def _assert_report_headers_are_correct
    within 'table thead tr' do
      page.should have_link 'Name'
      page.should have_link 'Serial Number'
      page.should have_link 'Status'
      page.should have_link 'Inspection Interval'
      page.should have_link 'Last Inspection Date'
      page.should have_link 'Type'
      page.should have_link 'Expiration Date'
      page.should have_link 'Assignee'
    end
  end
end