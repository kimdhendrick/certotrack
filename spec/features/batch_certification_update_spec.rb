require 'spec_helper'

describe 'Batch Certification Update', slow: true do
  let(:customer) { create(:customer) }

  describe 'Batch Update Employee' do
    let!(:employee) do
      create(:employee,
             employee_number: 'JB3',
             first_name: 'Joe',
             last_name: 'Brown',
             customer_id: customer.id
      )
    end
    let!(:level_one_certification) do
      level_one = create(:certification_type,
                         name: 'Level I Truck Inspection',
                         interval: Interval::SIX_MONTHS.text,
                         units_required: 10,
                         customer: customer
      )
      create(:certification,
             employee: employee,
             certification_type: level_one
      )

    end
    let!(:level_two_certification) do
      level_two = create(:certification_type,
                         name: 'Level II Truck Inspection',
                         interval: Interval::SIX_MONTHS.text,
                         units_required: 20,
                         customer: customer
      )
      create(:certification,
             employee: employee,
             certification_type: level_two
      )

    end
    let!(:level_three_certification) do
      level_three = create(:certification_type,
                         name: 'Level III Truck Inspection',
                         interval: Interval::SIX_MONTHS.text,
                         units_required: 30,
                         customer: customer
      )
      create(:certification,
             employee: employee,
             certification_type: level_three
      )

    end

    before do
      login_as_certification_user(customer)
    end

    it 'should update all certifications', js: true do
      visit employee_path employee.id

      page.should have_field 'Batch Edit Mode'

      check 'Batch Edit Mode'

      page.should have_button 'Update'
      page.should have_button 'Reset'

      click_on 'Reset'

      page.should_not have_button 'Update'
      page.should_not have_button 'Reset'

      check 'Batch Edit Mode'

      page.should have_button 'Update'
      page.should have_button 'Reset'

      uncheck 'Batch Edit Mode'

      page.should_not have_button 'Update'
      page.should_not have_button 'Reset'

      check 'Batch Edit Mode'

      fill_in "certification_ids_#{level_one_certification.id}", with: '5'
      fill_in "certification_ids_#{level_two_certification.id}", with: '15'
      fill_in "certification_ids_#{level_three_certification.id}", with: '25'

      click_on 'Update'

      page.should have_content 'Show Employee'
      page.should have_content 'Certifications updated successfully.'

      page.should have_content '5 of 10'
      page.should have_content '15 of 20'
      page.should have_content '25 of 30'

      # Error handling
      check 'Batch Edit Mode'

      fill_in "certification_ids_#{level_one_certification.id}", with: '555'
      fill_in "certification_ids_#{level_two_certification.id}", with: '-99'
      fill_in "certification_ids_#{level_three_certification.id}", with: '2500'

      click_on 'Update'

      page.should have_content 'Show Employee'
      page.should have_content 'Errors occurred during the batch update. See below for details.'
      page.should have_content 'Active certification period units achieved must be greater than or equal to 0'

      find_field("certification_ids_#{level_one_certification.id}").value.should eq '555'
      find_field("certification_ids_#{level_two_certification.id}").value.should eq '-99'
      find_field("certification_ids_#{level_three_certification.id}").value.should eq '2500'
    end
  end
end