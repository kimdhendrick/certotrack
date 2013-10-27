require 'spec_helper'

describe CertificationPresenter do
  include ActionView::TestCase::Behavior

  it 'should respond to id' do
    certification = create(:certification)
    CertificationPresenter.new(certification).id.should == certification.id
  end

  it 'should respond true to units_based?' do
    certification = create(:units_based_certification, customer: create(:customer))
    CertificationPresenter.new(certification).units_based?.should be_true
  end

  it 'should respond false to units_based?' do
    certification = create(:certification)
    CertificationPresenter.new(certification).units_based?.should be_false
  end

  it 'should respond to interval' do
    certification_type = create(
      :certification_type,
      customer: create(:customer),
      interval: Interval::THREE_MONTHS.text
    )
    certification = create(
      :certification,
      certification_type: certification_type,
      customer: certification_type.customer
    )

    CertificationPresenter.new(certification).interval.should == '3 months'
  end

  it 'should respond to trainer' do
    certification = create(
      :certification,
      customer: create(:customer),
      trainer: 'Trainer'
    )

    CertificationPresenter.new(certification).trainer.should == 'Trainer'
  end

  it 'should respond to status' do
    certification = create(
      :certification,
      customer: create(:customer),
      expiration_date: Date.new(2012, 4, 2)
    )

    CertificationPresenter.new(certification).status.should == certification.status
    CertificationPresenter.new(certification).status.text.should == 'Expired'
  end

  it 'should respond to comments' do
    certification = create(
      :certification,
      customer: create(:customer),
      comments: 'Hello!'
    )

    CertificationPresenter.new(certification).comments.should == 'Hello!'
  end

  it 'should respond to sort_key' do
    certification = create(
      :certification,
      customer: create(:customer),
      certification_type: create(:certification_type, name: 'Cert type 123'),
      comments: 'Hello!'
    )

    CertificationPresenter.new(certification).sort_key.should == 'Cert type 123'
  end

  it 'should respond to last_inspection_date' do
    certification = create(
      :certification,
      customer: create(:customer),
      last_certification_date: Date.new(2013, 5, 12)
    )

    CertificationPresenter.new(certification).last_certification_date.should == '05/12/2013'
  end

  it 'should respond to expiration_date' do
    certification = create(
      :certification,
      customer: create(:customer),
      expiration_date: Date.new(2012, 6, 20)
    )

    CertificationPresenter.new(certification).expiration_date.should == '06/20/2012'
  end

  it 'should respond to location' do
    location = create(:location)
    employee = create(:employee, location: location)
    certification = create(
      :certification,
      customer: create(:customer),
      employee: employee
    )

    CertificationPresenter.new(certification).location.should == location
  end

  it 'should respond to employee_name' do
    employee = create(:employee, first_name: 'First', last_name: 'Last')
    certification = create(
      :certification,
      customer: create(:customer),
      employee: employee
    )

    CertificationPresenter.new(certification).employee_name.should == 'Last, First'
  end

  it 'should respond to certification_type' do
    certification_type = create(:certification_type, name: 'CertType')
    certification = create(
      :certification,
      customer: create(:customer),
      certification_type: certification_type
    )

    CertificationPresenter.new(certification).certification_type.should == 'CertType'
  end

  it 'should respond to interval_code' do
    certification_type = create(:certification_type, interval: Interval::THREE_MONTHS.text)
    certification = create(:certification, certification_type: certification_type)

    CertificationTypePresenter.new(certification).interval_code.should == Interval::THREE_MONTHS.id
  end

  it 'should respond to units_required_sort_key' do
    certification_type = build(:certification_type, units_required: 3)
    certification = build(:certification, certification_type: certification_type)
    CertificationPresenter.new(certification).units_required_sort_key.should == 3
  end

  it 'should respond to employee' do
    employee = create(:employee)
    certification = create(
      :certification,
      customer: create(:customer),
      employee: employee,
      expiration_date: Date.new(2012, 6, 20)
    )

    presented_employee = CertificationPresenter.new(certification).employee
    presented_employee.should be_an_instance_of(EmployeePresenter)
    presented_employee.model.should == employee
  end

  describe 'units_achieved' do
    context 'when Certification is date based' do
      it 'should be blank' do
        certification = build(:certification)
        CertificationPresenter.new(certification).units_achieved_of_required.should be_blank
      end
    end
    context 'when Certification is unit based' do
      it 'should be the value of #units_achieved of #units_required' do
        certification = build(:units_based_certification)
        certification.units_achieved = 2
        certification.certification_type.units_required = 3
        CertificationPresenter.new(certification).units_achieved_of_required.should == '2 of 3'
      end
    end
  end

  describe 'units' do
    context 'when Certification is date based' do
      it 'should be blank' do
        certification = build(:certification)
        CertificationPresenter.new(certification).units.should be_blank
      end
    end
    context 'when Certification is unit based' do
      it 'should be the value of #units_achieved' do
        certification = build(:units_based_certification)
        certification.units_achieved = 2
        certification.certification_type.units_required = 3
        CertificationPresenter.new(certification).units.should == '2'
      end
    end
  end

  describe 'units_achieved_label' do
    context 'when Certification is date based' do
      it 'should be blank' do
        certification = build(:certification)
        CertificationPresenter.new(certification).units_achieved_label.should be_blank
      end
    end
    context 'when Certification is unit based' do
      it 'should be the value of #units_achieved_label of #units_required' do
        certification = build(:units_based_certification)
        certification.units_achieved = 2
        certification.certification_type.units_required = 3
        CertificationPresenter.new(certification).units_achieved_label.should == 'Units Achieved'
      end
    end
  end

  describe 'recertify_link' do
    it 'should create a link to the recertify page' do
      certification = create(:certification)
      subject = CertificationPresenter.new(certification, view)
      subject.recertify_link.should =~ /<a.*>Recertify<\/a>/
    end
  end

  subject { CertificationPresenter.new(build(:units_based_certification)) }
  it_behaves_like 'an object that is sortable by status'
end