require 'spec_helper'

describe CertificationFactory do
  describe 'new_instance' do
    it 'creates a certification' do
      certification_type = create(:certification_type)
      employee = create(:employee)

      certification = CertificationFactory.new.new_instance(
        employee.id,
        certification_type.id,
        '12/30/2000',
        'Joe Bob',
        'Great class!',
        15
      )

      certification.should_not be_persisted
      certification.employee.should == employee
      certification.customer.should == employee.customer
      certification.certification_type.should == certification_type
      certification.active_certification_period.trainer.should == 'Joe Bob'
      certification.active_certification_period.comments.should == 'Great class!'
      certification.last_certification_date.should == Date.new(2000, 12, 30)
      certification.units_achieved.should == 15
    end

    it 'handles bad date' do

      certification_type = create(:certification_type)
      employee = create(:employee)

      certification = CertificationFactory.new.new_instance(
        employee.id,
        certification_type.id,
        '999',
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
      certification_type = create(:certification_type, interval: Interval::ONE_MONTH.text)
      employee = create(:employee)
      fake_expiration_date = Date.new(2001, 1, 1)

      fake_expiration_calculator = FakeService.new(fake_expiration_date)
      certification_factory = CertificationFactory.new(expiration_calculator: fake_expiration_calculator)

      certification = certification_factory.new_instance(
        employee.id,
        certification_type.id,
        '12/15/2000',
        nil,
        nil
      )

      fake_expiration_calculator.received_message.should == :calculate
      fake_expiration_calculator.received_params[0].should == Date.new(2000, 12, 15)
      fake_expiration_calculator.received_params[1].should == Interval::ONE_MONTH
      certification.expiration_date.should == fake_expiration_date
    end
  end
end