require 'spec_helper'

describe CertificationPresenter do
  include ActionView::TestCase::Behavior

  it 'should respond to id' do
    certification = create(:certification)
    CertificationPresenter.new(certification).id.should == certification.id
  end

  it 'should respond true to units_based?' do
    certification = create(:units_based_certification)
    CertificationPresenter.new(certification).units_based?.should be_true
  end

  it 'should respond false to units_based?' do
    certification = create(:certification)
    CertificationPresenter.new(certification).units_based?.should be_false
  end

  it 'should respond to interval' do
    certification_type = create(:certification_type, interval: Interval::THREE_MONTHS.text)
    certification = create(:certification, certification_type: certification_type)

    CertificationPresenter.new(certification).interval.should == '3 months'
  end

  context '#trainer' do
    it 'should respond to trainer' do
      certification = create(:certification, trainer: 'Trainer')

      CertificationPresenter.new(certification).trainer.should == 'Trainer'
    end

    it 'should return nothing when status is not certified' do
      certification = build(:units_based_certification)
      certification.active_certification_period = nil

      CertificationPresenter.new(certification).trainer.should be_nil
    end
  end

  it 'should respond to status' do
    certification = create(:certification, expiration_date: Date.new(2012, 4, 2))

    CertificationPresenter.new(certification).status.should == certification.status
    CertificationPresenter.new(certification).status.text.should == 'Expired'
  end

  context '#comments' do
    it 'should respond to comments' do
      certification = create(:certification, comments: 'Hello!')

      CertificationPresenter.new(certification).comments.should == 'Hello!'
    end

    it 'should return nothing when status is not certified' do
      certification = build(:units_based_certification)
      certification.active_certification_period = nil

      CertificationPresenter.new(certification).comments.should be_nil
    end
  end

  it 'should respond to sort_key' do
    certification = create(
      :certification,
      certification_type: create(:certification_type, name: 'Cert type 123')
    )

    CertificationPresenter.new(certification).sort_key.should == 'Cert type 123'
  end

  it 'should respond to last_certification_date' do
    certification = create(
      :certification,
      last_certification_date: Date.new(2013, 5, 12)
    )

    CertificationPresenter.new(certification).last_certification_date.should == '05/12/2013'
  end

  context '#expiration_date' do
    it 'should respond to expiration_date' do
      certification = create(
        :certification,
        expiration_date: Date.new(2012, 6, 20)
      )

      CertificationPresenter.new(certification).expiration_date.should == '06/20/2012'
    end

    it 'should return nothing when status is not certified' do
      certification = build(:units_based_certification)
      certification.active_certification_period = nil

      CertificationPresenter.new(certification).expiration_date.should be_nil
    end
  end

  it 'should respond to last_certification_date_sort_key' do
    certification = create(
      :certification,
      last_certification_date: Date.new(2013, 5, 12)
    )

    CertificationPresenter.new(certification).last_certification_date_sort_key.should == Date.new(2013, 5, 12)
  end

  it 'should respond to expiration_date_sort_key' do
    certification = create(
      :certification,
      expiration_date: Date.new(2012, 6, 20)
    )

    CertificationPresenter.new(certification).expiration_date_sort_key.should == Date.new(2012, 6, 20)
  end

  it 'should respond to location' do
    location = create(:location)
    employee = create(:employee, location: location)
    certification = create(:certification, employee: employee)

    CertificationPresenter.new(certification).location.should == location
  end

  it 'should respond to location_name' do
    location = create(:location, name: 'Golden')
    employee = create(:employee, location: location)
    certification = create(:certification, employee: employee)

    CertificationPresenter.new(certification).location_name.should == 'Golden'
  end

  it 'should respond to employee_name' do
    employee = create(:employee, first_name: 'First', last_name: 'Last')
    certification = create(:certification, employee: employee)

    CertificationPresenter.new(certification).employee_name.should == 'Last, First'
  end

  it 'should respond to employee_number' do
    employee = create(:employee, first_name: 'First', last_name: 'Last', employee_number: 'ABC123')
    certification = create(:certification, employee: employee)

    CertificationPresenter.new(certification).employee_number.should == 'ABC123'
  end

  it 'should respond to certification_type' do
    certification_type = create(:certification_type, name: 'CertType')
    certification = create(:certification, certification_type: certification_type)

    CertificationPresenter.new(certification).certification_type.should == 'CertType'
  end

  it 'should respond to interval_code' do
    certification_type = create(:certification_type, interval: Interval::THREE_MONTHS.text)

    CertificationTypePresenter.new(certification_type).interval_code.should == Interval::THREE_MONTHS.id
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

      it 'should return nothing when status is not certified' do
        certification = build(:units_based_certification)
        certification.active_certification_period = nil

        CertificationPresenter.new(certification).units_achieved_of_required.should be_nil
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

      it 'should return nothing when status is not certified' do
        certification = build(:units_based_certification)
        certification.active_certification_period = nil

        CertificationPresenter.new(certification).units.should be_nil
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

  describe 'show_link' do
    it 'should create a link to the show page' do
      certification = create(:certification)
      subject = CertificationPresenter.new(certification, view)
      subject.show_link.should =~ /<a.*>Back to certification<\/a>/
    end
  end

  describe 'show_history_link' do
    it 'should create a link to the show history page' do
      certification = create(:certification)
      subject = CertificationPresenter.new(certification, view)
      subject.show_history_link.should =~ /<a.*>Certification History<\/a>/
    end
  end

  subject { CertificationPresenter.new(build(:units_based_certification)) }
  it_behaves_like 'an object that is sortable by status'

  it 'should respond to status_text' do
    certification = CertificationPresenter.new(create(:certification))
    certification.status_text.should == 'N/A'
  end

  it 'should respond to created_by' do
    certification = CertificationPresenter.new(create(:certification, created_by: 'username'))
    certification.created_by.should == 'username'
  end

  it 'should respond to created_at' do
    certification = CertificationPresenter.new(create(:certification, created_at: Date.new(2010, 1, 1)))
    certification.created_at.should == '01/01/2010'
  end

  describe 'edit_link' do
    it 'should create a link to the edit page' do
      certification = create(:certification)
      subject = CertificationPresenter.new(certification, view)
      subject.edit_link.should =~ /<a.*>Edit<\/a>/
    end
  end

  describe 'delete_link' do
    it 'should create a link to the delete page' do
      certification = create(:certification)
      subject = CertificationPresenter.new(certification, view)
      subject.delete_link.should =~ /<a.*>Delete<\/a>/
    end
  end
end