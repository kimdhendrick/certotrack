require 'spec_helper'

describe 'Recertify Employee', js: true do

  let(:customer) { create(:customer) }
  let(:certification) { create(:units_based_certification, customer: customer) }
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
    end

    it 'should have Certification Type' do
      subject.should have_content('Certification Type')
      subject.should have_content(certification.certification_type.name)
    end

    it 'should not have link to create certification type' do
      subject.should have_no_link('Create Certification Type')
    end

    it 'should not have drop down for certification type' do
      subject.should have_no_select('Certification Type')
    end

    it 'should have Trainer field'

    it 'should have Last Certification Date field'

    it 'should have Comments field'


    context 'when units based certification' do
      it 'should have Units Achieved field'

    end
  end
end