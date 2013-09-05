require 'spec_helper'

describe 'Employee Certifications' do
  describe 'Show Employee' do
    let(:employee) { FactoryGirl.create(:employee, customer: @customer) }

    before do
      login_as_certification_user
    end

    it 'should show certifications' do
      FactoryGirl.create(:certification, employee: employee)

      visit employee_path(employee)
      page.should have_content 'Show Employee'

      within 'table thead tr:nth-of-type(1)' do
        page.should have_link 'Certification Type'
        page.should have_content 'Trainer'
        page.should have_content 'Expiration Date'
        page.should have_content 'Last Certification Date'
        page.should have_content 'Units'
        page.should have_link 'Status'
      end

      within 'table tbody tr:nth-of-type(1)' do
        page.should have_content 'Scrum Master'
        page.should have_content DateHelpers::date_to_string(1.day.ago)
        page.should have_content '0'
        page.should have_content 'N/A'
      end
    end

    context 'sorting' do
      let(:scrum_master_certification_type) { FactoryGirl.create(:certification_type, name: 'Scrum Master') }
      let(:scrum_coach_certification_type) { FactoryGirl.create(:certification_type, name: 'Scrum Coach') }

      before do
        
      end

      it 'should sort by certification type (name)' do
        FactoryGirl.create(:certification, employee: employee, certification_type: scrum_master_certification_type)
        FactoryGirl.create(:certification, employee: employee, certification_type: scrum_coach_certification_type)
        visit employee_path(employee)

        within 'table thead tr:nth-of-type(1)' do
          click_link 'Certification Type'
        end

        column_data_should_be_in_order('Scrum Coach', 'Scrum Master')

        within 'table thead tr:nth-of-type(1)' do
          click_link 'Certification Type'
        end

        column_data_should_be_in_order('Scrum Master', 'Scrum Coach')
      end

      it 'should sort by status' do
        FactoryGirl.create(:units_based_certification, employee: employee)
        FactoryGirl.create(:certification, employee: employee)
        visit employee_path(employee)

        within 'table thead tr:nth-of-type(1)' do
          click_link 'Status'
        end

        column_data_should_be_in_order(Status::RECERTIFY.text, Status::NA.text)

        within 'table thead tr:nth-of-type(1)' do
          click_link 'Status'
        end

        column_data_should_be_in_order(Status::NA.text, Status::RECERTIFY.text)
      end
    end

    context 'pagination' do
      before do
        26.times do |n|
          certification_type = FactoryGirl.create(:certification_type, name: "type-#{n}")
          FactoryGirl.create(:certification, employee: employee, certification_type: certification_type)
        end
        visit employee_path(employee)
      end

      it 'should paginate employee certifications report' do
        find 'table.sortable'

        page.all('table tr').count.should == 26
        within 'div.pagination' do
          page.should_not have_link 'Previous'
          page.should_not have_link '1'
          page.should have_link '2'
          page.should have_link 'Next'

          click_link 'Next'
        end

        page.all('table tr').count.should == 2
        within 'div.pagination' do
          page.should have_link 'Previous'
          page.should have_link '1'
          page.should_not have_link '2'
          page.should_not have_link 'Next'

          click_link 'Previous'
        end

        within 'div.pagination' do
          page.should_not have_link 'Previous'
          page.should_not have_link '1'
          page.should have_link '2'
          page.should have_link 'Next'

          click_link 'Next'
        end
      end
    end
  end
end