require 'spec_helper'

describe CertificationService do
  describe 'new_certification' do
    it 'calls CertificationFactory' do
      employee = create_employee
      certification = new_certification
      certification_service = CertificationService.new
      fake_certification_factory = certification_service.load_certification_factory(FakeService.new(certification))

      certification = certification_service.new_certification(employee.id)

      fake_certification_factory.received_message.should == :new_instance
      fake_certification_factory.received_params[0].should == employee.id
      certification.should_not be_persisted
    end
  end

  describe 'certify' do
    it 'creates a certification' do
      employee = create_employee
      certification_type = create_certification_type
      certification = new_certification
      certification_service = CertificationService.new
      fake_certification_factory = certification_service.load_certification_factory(FakeService.new(certification))

      certification = certification_service.certify(
        employee.id,
        certification_type.id,
        '12/31/2000',
        'Joe Bob',
        'Great class!'
      )

      fake_certification_factory.received_message.should == :new_instance
      fake_certification_factory.received_params[0].should == employee.id
      fake_certification_factory.received_params[1].should == certification_type.id
      fake_certification_factory.received_params[2].should == '12/31/2000'
      fake_certification_factory.received_params[3].should == 'Joe Bob'
      fake_certification_factory.received_params[4].should == 'Great class!'
      certification.should be_persisted
    end

    it 'handles bad date' do
      employee = create_employee
      certification_type = create_certification_type
      certification = Certification.new
      certification_service = CertificationService.new
      fake_certification_factory = certification_service.load_certification_factory(FakeService.new(certification))

      certification = certification_service.certify(
        employee.id,
        certification_type.id,
        '999',
        'Joe Bob',
        'Great class!'
      )

      certification.should_not be_valid
      certification.should_not be_persisted
      fake_certification_factory.received_message.should == :new_instance
      fake_certification_factory.received_params[0].should == employee.id
      fake_certification_factory.received_params[1].should == certification_type.id
      fake_certification_factory.received_params[2].should == '999'
      fake_certification_factory.received_params[3].should == 'Joe Bob'
      fake_certification_factory.received_params[4].should == 'Great class!'
    end
  end
end