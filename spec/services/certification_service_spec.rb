require 'spec_helper'

describe CertificationService do
  describe 'new_certification' do
    it 'returns a new certification' do
      employee = create_employee

      certification = CertificationService.new.new_certification(employee.id)

      certification.should be_a(Certification)
      certification.employee.should == employee
      certification.active_certification_period.should be_a(CertificationPeriod)
      certification.should_not be_persisted
    end
  end

  describe 'certify' do
    it 'creates a certification' do
      certification_type = create_certification_type
      employee = create_employee

      certification = CertificationService.new.certify(
        employee.id,
        certification_type.id,
        Date.new(2000, 1, 1),
        'Joe Bob',
        'Great class!'
      )

      certification.should be_persisted
      certification.employee.should == employee
      certification.certification_type.should == certification_type
      certification.active_certification_period.trainer.should == 'Joe Bob'
      certification.active_certification_period.comments.should == 'Great class!'
      certification.last_certification_date.should == Date.new(2000, 1, 1)
    end

    it 'calculates expiration date using calculator' do
      certification_type = create_certification_type
      employee = create_employee
      last_certification_date = Date.new(2000, 1, 1)
      fake_expiration_date = Date.new(2001, 1, 1)

      certification_factory = CertificationService.new
      fake_expiration_calculator = certification_factory.load_expiration_calculator(FakeService.new(fake_expiration_date))

      certification = certification_factory.certify(
        employee.id,
        certification_type.id,
        last_certification_date,
        nil,
        nil
      )

      fake_expiration_calculator.received_message.should == :calculate
      fake_expiration_calculator.received_params[0].should == last_certification_date
      fake_expiration_calculator.received_params[1].should == certification_type.interval
      certification.expiration_date.should == fake_expiration_date
    end
  end
end