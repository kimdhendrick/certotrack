require 'spec_helper'

describe CertificationService do
  describe 'new_certification' do
    it 'calls CertificationFactory' do
      employee = create(:employee)
      certification_type = create(:certification_type)
      certification = build(:certification, employee: employee)
      fake_certification_factory = FakeService.new(certification)
      certification_service = CertificationService.new(certification_factory: fake_certification_factory)

      certification = certification_service.new_certification(employee.id, certification_type.id)

      fake_certification_factory.received_message.should == :new_instance
      fake_certification_factory.received_params[0][:employee_id].should == employee.id
      fake_certification_factory.received_params[0][:certification_type_id].should == employee.id
      certification.should_not be_persisted
    end
  end

  describe 'certify' do
    it 'creates a certification' do
      employee = create(:employee)
      certification_type = create(:certification_type)
      certification = build(:certification, certification_type: certification_type, employee: employee, customer: employee.customer)
      fake_certification_factory = FakeService.new(certification)
      certification_service = CertificationService.new(certification_factory: fake_certification_factory)

      certification = certification_service.certify(
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
      fake_certification_factory = FakeService.new(certification)
      certification_service = CertificationService.new(certification_factory: fake_certification_factory)

      certification = certification_service.certify(
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

  describe '#get_all_certifications_for_employee' do

    it 'returns all certifications for a given employee' do
      employee_1 = create(:employee)
      employee_2 = create(:employee)
      certification_1 = create(:certification, employee: employee_1, customer: employee_1.customer)
      certification_2 = create(:certification, employee: employee_2, customer: employee_2.customer)

      subject = CertificationService.new

      subject.get_all_certifications_for_employee(employee_1).should == [certification_1]
      subject.get_all_certifications_for_employee(employee_2).should == [certification_2]
    end

    it 'only returns active certifications' do
      employee_1 = create(:employee)
      active_certification = create(:certification, employee: employee_1, customer: employee_1.customer)
      inactive_certification = create(:certification, active: false, employee: employee_1, customer: employee_1.customer)

      subject = CertificationService.new

      subject.get_all_certifications_for_employee(employee_1).should == [active_certification]
    end

    context 'sorting' do
      it 'should call Sorter to ensure sorting' do
        fake_sorter = FakeService.new([])

        subject = CertificationService.new(sorter: fake_sorter)

        subject.get_all_certifications_for_employee(build(:employee))

        fake_sorter.received_message.should == :sort
      end
    end

    context 'pagination' do
      it 'should call Paginator to paginate results' do
        fake_paginator = FakeService.new

        subject = CertificationService.new(paginator: fake_paginator)

        subject.get_all_certifications_for_employee(build(:employee))

        fake_paginator.received_message.should == :paginate
      end
    end
  end

  describe '#get_all_certifications_for_certification_type' do

    it 'returns all certifications for a given certification_type' do
      certification_type_1 = create(:certification_type)
      certification_type_2 = create(:certification_type)
      certification_1 = create(:certification, certification_type: certification_type_1, customer: certification_type_1.customer)
      certification_2 = create(:certification, certification_type: certification_type_2, customer: certification_type_2.customer)

      subject = CertificationService.new

      subject.get_all_certifications_for_certification_type(certification_type_1).should == [certification_1]
      subject.get_all_certifications_for_certification_type(certification_type_2).should == [certification_2]
    end

    it 'only returns active certifications' do
      certification_type = create(:certification_type)
      active_certification = create(:certification, certification_type: certification_type, customer: certification_type.customer)
      inactive_certification = create(:certification, active: false, certification_type: certification_type, customer: certification_type.customer)

      subject = CertificationService.new

      subject.get_all_certifications_for_certification_type(certification_type).should == [active_certification]
    end

    context 'sorting' do
      it 'should call Sorter to ensure sorting' do
        fake_sorter = FakeService.new([])

        subject = CertificationService.new(sorter: fake_sorter)

        subject.get_all_certifications_for_certification_type(build(:certification_type))

        fake_sorter.received_message.should == :sort
      end
    end

    context 'pagination' do
      it 'should call Paginator to paginate results' do
        fake_paginator = FakeService.new

        subject = CertificationService.new(paginator: fake_paginator)

        subject.get_all_certifications_for_certification_type(build(:certification_type))

        fake_paginator.received_message.should == :paginate
      end
    end
  end
end