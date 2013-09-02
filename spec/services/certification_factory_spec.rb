require 'spec_helper'

describe CertificationFactory do
  describe 'new_instance' do
    it 'creates a certification' do
      certification_type = create_certification_type
      employee = create_employee

      certification = CertificationFactory.new.new_instance(
        employee.id,
        certification_type.id,
        Date.new(2000, 1, 1),
        'Joe Bob',
        'Great class!'
      )

      certification.should_not be_persisted
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

      certification_factory = CertificationFactory.new
      fake_expiration_calculator = certification_factory.load_expiration_calculator(FakeService.new(fake_expiration_date))

      certification = certification_factory.new_instance(
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

    it 'handles bad date' do

      certification_type = create_certification_type
      employee = create_employee

      certification = CertificationFactory.new.new_instance(
        employee.id,
        certification_type.id,
        nil,
        'Joe Bob',
        'Great class!'
      )

      certification.should_not be_persisted
      certification.should_not be_valid
      certification.active_certification_period.should_not be_valid
      certification.employee.should == employee
      certification.certification_type.should == certification_type
      certification.active_certification_period.trainer.should == 'Joe Bob'
      certification.active_certification_period.comments.should == 'Great class!'
      certification.last_certification_date.should == nil
    end

    it 'calculates expiration date using calculator' do
      certification_type = create_certification_type
      employee = create_employee
      last_certification_date = Date.new(2000, 1, 1)
      fake_expiration_date = Date.new(2001, 1, 1)

      certification_factory = CertificationFactory.new
      fake_expiration_calculator = certification_factory.load_expiration_calculator(FakeService.new(fake_expiration_date))

      certification = certification_factory.new_instance(
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