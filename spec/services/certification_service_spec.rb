require 'spec_helper'

describe CertificationService do
  describe 'new_certification' do
    it 'calls CertificationFactory' do
      user = create(:user)
      employee = create(:employee)
      certification_type = create(:certification_type)
      certification = build(:certification, employee: employee)
      fake_certification_factory = Faker.new(certification)
      certification_service = CertificationService.new(certification_factory: fake_certification_factory)

      certification = certification_service.new_certification(user, employee.id, certification_type.id)

      fake_certification_factory.received_message.should == :new_instance
      fake_certification_factory.received_params[0][:current_user_id].should == user.id
      fake_certification_factory.received_params[0][:employee_id].should == employee.id
      fake_certification_factory.received_params[0][:certification_type_id].should == employee.id
      certification.should_not be_persisted
    end
  end

  describe 'certify' do
    it 'creates a certification' do
      employee = create(:employee)
      certification_type = create(:certification_type)
      certification = build(:certification, certification_type: certification_type, employee: employee)
      fake_certification_factory = Faker.new(certification)
      certification_service = CertificationService.new(certification_factory: fake_certification_factory)

      certification = certification_service.certify(
        create(:user),
        employee.id,
        certification_type.id,
        '12/31/2000',
        'Joe Bob',
        'Great class!',
        '15'
      )

      fake_certification_factory.received_message.should == :new_instance
      fake_certification_factory.received_params[0][:employee_id].should == employee.id
      fake_certification_factory.received_params[0][:certification_type_id].should == certification_type.id
      fake_certification_factory.received_params[0][:certification_date].should == '12/31/2000'
      fake_certification_factory.received_params[0][:trainer].should == 'Joe Bob'
      fake_certification_factory.received_params[0][:comments].should == 'Great class!'
      fake_certification_factory.received_params[0][:units_achieved].should == '15'
      certification.should be_persisted
    end

    it 'handles bad date' do
      employee = create(:employee)
      certification_type = create(:certification_type)
      certification = Certification.new
      fake_certification_factory = Faker.new(certification)
      certification_service = CertificationService.new(certification_factory: fake_certification_factory)

      certification = certification_service.certify(
        create(:user),
        employee.id,
        certification_type.id,
        '999',
        'Joe Bob',
        'Great class!',
        nil
      )

      certification.should_not be_valid
      certification.should_not be_persisted
      fake_certification_factory.received_message.should == :new_instance
      fake_certification_factory.received_params[0][:employee_id].should == employee.id
      fake_certification_factory.received_params[0][:certification_type_id].should == certification_type.id
      fake_certification_factory.received_params[0][:certification_date].should == '999'
      fake_certification_factory.received_params[0][:trainer].should == 'Joe Bob'
      fake_certification_factory.received_params[0][:comments].should == 'Great class!'
      fake_certification_factory.received_params[0][:units_achieved].should == nil
    end
  end

  describe '#update_certification' do
    it 'should update certifications attributes' do
      employee = create(:employee)
      certification_type = create(:certification_type, interval: Interval::ONE_YEAR.text, units_required: 20)

      certification = create(:certification)
      attributes = {
        'employee_id' => employee.id,
        'certification_type_id' => certification_type.id,
        'last_certification_date' => '03/05/2013',
        'trainer' => 'Trainer',
        'comments' => 'Comments',
        'units_achieved' => '12'
      }

      success = CertificationService.new.update_certification(certification, attributes)
      success.should be_true

      certification.reload
      certification.employee_id.should == employee.id
      certification.certification_type_id.should == certification_type.id
      certification.last_certification_date.should == Date.new(2013, 3, 5)
      certification.expiration_date.should == Date.new(2014, 3, 5)
      certification.trainer.should == 'Trainer'
      certification.comments.should == 'Comments'
      certification.units_achieved.should == 12
    end

    it 'should return false if errors' do
      certification = create(:certification)
      certification.stub(:save).and_return(false)

      success = CertificationService.new.update_certification(certification, {})
      success.should be_false
    end
  end

  describe '#get_all_certifications_for_employee' do

    it 'returns all certifications for a given employee' do
      employee_1 = create(:employee)
      employee_2 = create(:employee)
      certification_1 = create(:certification, employee: employee_1)
      certification_2 = create(:certification, employee: employee_2)

      subject = CertificationService.new

      subject.get_all_certifications_for_employee(employee_1).should == [certification_1]
      subject.get_all_certifications_for_employee(employee_2).should == [certification_2]
    end

    it 'only returns active certifications' do
      employee_1 = create(:employee)
      active_certification = create(:certification, employee: employee_1)
      inactive_certification = create(:certification, active: false, employee: employee_1)

      subject = CertificationService.new

      subject.get_all_certifications_for_employee(employee_1).should == [active_certification]
    end
  end

  describe '#get_all_certifications_for_certification_type' do

    it 'returns all certifications for a given certification_type' do
      certification_type_1 = create(:certification_type)
      certification_type_2 = create(:certification_type)
      certification_1 = create(:certification, certification_type: certification_type_1)
      certification_2 = create(:certification, certification_type: certification_type_2)

      subject = CertificationService.new

      subject.get_all_certifications_for_certification_type(certification_type_1).should == [certification_1]
      subject.get_all_certifications_for_certification_type(certification_type_2).should == [certification_2]
    end

    it 'only returns active certifications' do
      certification_type = create(:certification_type)
      active_certification = create(:certification, certification_type: certification_type)
      inactive_certification = create(:certification, active: false, certification_type: certification_type)

      subject = CertificationService.new

      subject.get_all_certifications_for_certification_type(certification_type).should == [active_certification]
    end
  end
end