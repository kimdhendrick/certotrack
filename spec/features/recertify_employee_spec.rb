require 'spec_helper'

describe 'Recertify Employee' do

  let(:customer) { create(:customer) }
  let(:certification_period) { create(:units_based_certification_period) }
  let(:certification) { create(:units_based_certification, customer: customer, active_certification_period: certification_period) }
  subject { page }

  before do
    login_as_certification_user(customer)
    visit certification_path(certification)
  end

  describe 'show certification page' do
    it { should have_link('Recertify') }
  end

  describe 'recertify page' do
    before { click_link('Recertify') }

    it 'should have Recertify heading' do
      subject.should have_content('Recertify Employee')
    end

    it 'should have Employee' do
      subject.should have_content('Employee')
      subject.should have_content(certification.employee.first_name)
      subject.should have_content(certification.employee.last_name)
      subject.should have_link("#{certification.employee.first_name} #{certification.employee.last_name}", href: employee_path(certification.employee))
    end

    it 'should have Certification Type' do
      subject.should have_content('Certification Type')
      subject.should have_content(certification.certification_type.name)
      subject.should have_link("#{certification.certification_type.name}", href: certification_type_path(certification.certification_type))
    end

    it 'should not have link to create certification type' do
      subject.should have_no_link('Create Certification Type')
    end

    it 'should not have drop down for certification type' do
      subject.should have_no_select('Certification Type')
    end

    it 'should have Trainer field' do
      subject.should have_field('Trainer')
    end

    it 'should have the original Trainer value' do
      find_field('Trainer').value.should eq 'Trainer'
    end

    it 'should have Last Certification Date field' do
      subject.should have_field('Last Certification Date')
    end

    it 'should have the original Last Certification Date value' do
      find_field('Last Certification Date').value.should eq '05/15/2013'
    end

    it 'should have Comments field' do
      subject.should have_field('Comments')
    end

    it 'should have the original Comments value' do
      find_field('Comments').value.should eq 'Comments'
    end

    context 'when units based certification' do
      it 'should have Units Achieved field' do
        subject.should have_field('Units Achieved')
      end

      it 'should have the original Units Achieved value' do
      find_field('Units Achieved').value.should eq '0'
    end
    end

    context 'when date based certification', slow: true, js: true do
      let(:certification) { create(:date_based_certification, customer: customer) }

      it 'should NOT have Units Achieved field' do
        subject.should have_no_field('Units Achieved')
      end
    end

    describe 'click recertify' do
      context 'with valid data' do
        let!(:original_certification_period) { certification.active_certification_period }

        before do
          fill_in 'Trainer', with: 'Instructor Joe'
          fill_in 'Last Certification Date', with: '01/01/2000'
          fill_in 'Comments', with: 'Recertifying'
          click_button 'Recertify'
        end

        it 'should display success message' do
          subject.should have_content 'Smith, John recertified for Certification: Scrum Master'
        end

        it 'should recertify employee' do
          certification.reload
          certification.active_certification_period.start_date.should == Date.new(2000, 1, 1)
          certification.active_certification_period.comments.should == 'Recertifying'
          certification.active_certification_period.trainer.should == 'Instructor Joe'
          certification.certification_periods.should include(original_certification_period)
        end
      end

      context 'with invalid data' do
        it 'should display error message' do
          fill_in 'Trainer', with: 'Instructor Joe'
          fill_in 'Last Certification Date', with: ''
          fill_in 'Comments', with: 'Recertifying'
          click_button 'Recertify'

          subject.should have_content 'Recertify Employee'
          subject.should have_content('Last certification date is not a valid date')
        end
      end
    end
  end
end