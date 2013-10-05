require 'spec_helper'

describe CertificationPresenter do
  it 'should respond true to units_based?' do
    certification = create(:units_based_certification, customer: create(:customer))
    CertificationPresenter.new(certification, nil).units_based?.should be_true
  end

  it 'should respond false to units_based?' do
    certification = create(:certification, customer: create(:customer))
    CertificationPresenter.new(certification, nil).units_based?.should be_false
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

    CertificationPresenter.new(certification, nil).interval.should == '3 months'
  end

  it 'should respond to trainer' do
    certification = create(
      :certification,
      customer: create(:customer),
      trainer: 'Trainer'
    )

    CertificationPresenter.new(certification, nil).trainer.should == 'Trainer'
  end

  it 'should respond to status' do
    certification = create(
      :certification,
      customer: create(:customer),
      expiration_date: Date.new(2012, 4, 2)
    )

    CertificationPresenter.new(certification, nil).status.should == certification.status
    CertificationPresenter.new(certification, nil).status.text.should == 'Expired'
  end

  it 'should respond to comments' do
    certification = create(
      :certification,
      customer: create(:customer),
      comments: 'Hello!'
    )

    CertificationPresenter.new(certification, nil).comments.should == 'Hello!'
  end

  it 'should respond to sort_key' do
    certification = create(
      :certification,
      customer: create(:customer),
      certification_type: create(:certification_type, name: 'Cert type 123'),
      comments: 'Hello!'
    )

    CertificationPresenter.new(certification, nil).sort_key.should == 'Cert type 123'
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

  it 'should present EmployeePresenter' do
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
end