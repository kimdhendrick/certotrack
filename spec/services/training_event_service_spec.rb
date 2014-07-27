require 'spec_helper'

describe TrainingEventService do

  describe '#create_training_event' do

    subject { TrainingEventService.new }
    let(:current_user) { create(:user) }

    it 'should certify employees for certification types' do
      employee = create(:employee)
      certification_type = create(:certification_type)

      result = subject.create_training_event(current_user, [employee.id], [certification_type.id], '11/09/2013', 'Myself', 'comments')

      result.should ==
        {
          success: true,
          employees_with_errors: [],
          certification_types_with_errors: []
        }

      new_certification = Certification.last
      new_certification.employee.should == employee
      new_certification.certification_type.should == certification_type
      new_certification.trainer.should == 'Myself'
      new_certification.last_certification_date.should == Date.new(2013, 11, 9)
      new_certification.customer.should == current_user.customer
      new_certification.comments.should == 'comments'
    end

    it 'should return errors when invalid certifications' do
      bad_employee = create(:employee)
      bad_certification_type = create(:certification_type)

      invalid_certification = build(:certification, employee: bad_employee, certification_type: bad_certification_type)
      invalid_certification.stub(:valid?).and_return(false)
      fake_certification_service = Faker.new(invalid_certification)

      subject = TrainingEventService.new({certification_service: fake_certification_service})
      result = subject.create_training_event(current_user, [bad_employee.id], [bad_certification_type.id], '11/09/2013', 'Myself', 'comments')
      result.should ==
        {
          success: false,
          employees_with_errors: [bad_employee],
          certification_types_with_errors: [bad_certification_type]
        }

      Certification.count.should == 0
    end

    it 'should recertify' do
      employee = create(:employee)
      certification_type = create(:certification_type)
      existing_certification = create(
        :certification,
        employee: employee,
        certification_type: certification_type,
        last_certification_date: '01/01/2013',
        customer: current_user.customer
      )

      result = subject.create_training_event(current_user, [employee.id], [certification_type.id], '11/09/2013', 'Myself', 'comments')

      result[:success].should == true

      existing_certification.reload
      existing_certification.certification_periods.first.start_date.should == Date.new(2013, 1, 1)
      existing_certification.last_certification_date.should == Date.new(2013, 11, 9)
      existing_certification.employee.should == employee
      existing_certification.certification_type.should == certification_type
      existing_certification.trainer.should == 'Myself'
      existing_certification.customer.should == current_user.customer
      existing_certification.comments.should == 'comments'
    end

    it 'should handle errors on invalid recertification' do
      bad_employee = create(:employee)
      bad_certification_type = create(:certification_type)
      existing_certification = create(
        :certification,
        employee: bad_employee,
        certification_type: bad_certification_type,
        last_certification_date: '01/01/2013',
        customer: current_user.customer
      )

      subject = TrainingEventService.new({certification_service: Faker.new(false)})

      result = subject.create_training_event(current_user, [bad_employee.id], [bad_certification_type.id], '11/09/2013', 'Myself', 'comments')

      result.should ==
        {
          success: false,
          employees_with_errors: [bad_employee],
          certification_types_with_errors: [bad_certification_type]
        }

      existing_certification.reload
      existing_certification.last_certification_date.should == Date.new(2013, 1, 1)
    end
  end
end