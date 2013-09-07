require 'spec_helper'

describe CertificationService do
  describe 'new_certification' do
    it 'calls CertificationFactory' do
      employee = create(:employee)
      certification = build(:certification, employee: employee)
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
      employee = create(:employee)
      certification_type = create(:certification_type)
      certification = build(:certification, certification_type: certification_type, employee: employee)
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
      employee = create(:employee)
      certification_type = create(:certification_type)
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

  describe '#get_all_certifications_for' do
    subject { CertificationService.new }
    it 'returns all certifications for a given employee' do
      employee_1 = create(:employee)
      employee_2 = create(:employee)
      certification_1 = create(:certification, employee: employee_1)
      certification_2 = create(:certification, employee: employee_2)

      subject.get_all_certifications_for(employee_1).should == [certification_1]
      subject.get_all_certifications_for(employee_2).should == [certification_2]
    end

    context 'sorting' do
      it 'should call SortService to ensure sorting' do
        fake_sort_service = subject.load_sort_service(FakeService.new([]))

        subject.get_all_certifications_for(build(:employee))

        fake_sort_service.received_message.should == :sort
      end
    end

    context 'pagination' do
      it 'should call PaginationService to paginate results' do
        subject.load_sort_service(FakeService.new)
        fake_pagination_service = subject.load_pagination_service(FakeService.new)

        subject.get_all_certifications_for(build(:employee))

        fake_pagination_service.received_message.should == :paginate
      end
    end
  end
end