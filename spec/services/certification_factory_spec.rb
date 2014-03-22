require 'spec_helper'

describe CertificationFactory do
  describe 'new_instance' do

    it 'creates a certification when given no certification data' do
      customer = create(:customer)
      certification = CertificationFactory.new.new_instance(
        current_user_id: create(:user, customer: customer).id
      )

      certification.should_not be_persisted
      certification.errors.should be_empty
      certification.customer.should == customer
    end

    it 'should only have one error on blank start date' do
      customer = create(:customer)
      certification = CertificationFactory.new.new_instance(
        current_user_id: create(:user, customer: customer).id
      )
      certification.valid?

      certification.errors.full_messages_for(:"active_certification_period.start_date").first.should == 'Last certification date is not a valid date'
      certification.errors.full_messages_for(:"certification_periods.start_date").should be_empty
    end

    it 'creates a certification when given an employee_id' do
      certification_type = create(:certification_type)
      customer = create(:customer)
      employee = create(:employee)

      certification = CertificationFactory.new.new_instance(
        current_user_id: create(:user, customer: customer).id,
        employee_id: employee.id,
        certification_type_id: certification_type.id,
        certification_date: '12/30/2000',
        trainer: 'Joe Bob',
        comments: 'Great class!',
        units_achieved: 15
      )

      certification.should_not be_persisted
      certification.employee.should == employee
      certification.customer.should == customer
      certification.certification_type.should == certification_type
      certification.active_certification_period.trainer.should == 'Joe Bob'
      certification.active_certification_period.comments.should == 'Great class!'
      certification.last_certification_date.should == Date.new(2000, 12, 30)
      certification.units_achieved.should == 15
    end

    it 'creates a certification when given a certification_type_id' do
      customer = create(:customer)
      certification_type = create(:certification_type)

      certification = CertificationFactory.new.new_instance(
        current_user_id: create(:user, customer: customer).id,
        employee_id: nil,
        certification_type_id: certification_type.id
      )

      certification.should_not be_persisted
      certification.customer.should == customer
      certification.certification_type.should == certification_type
    end

    it 'handles bad date' do

      certification_type = create(:certification_type)
      employee = create(:employee)

      certification = CertificationFactory.new.new_instance(
        current_user_id: create(:user).id,
        employee_id: employee.id,
        certification_type_id: certification_type.id,
        certification_date: '999',
        trainer: 'Joe Bob',
        comments: 'Great class!'
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
      fake_expiration_date = Date.new(2001, 1, 15)

      certification_factory = CertificationFactory.new

      certification = certification_factory.new_instance(
        current_user_id: create(:user).id,
        employee_id: employee.id,
        certification_type_id: certification_type.id,
        certification_date: '12/15/2000',
        trainer: nil,
        comments: nil
      )

      certification.expiration_date.should == fake_expiration_date
    end

    it 'sets the current_user as the creator' do
      certification_type = create(:certification_type)
      customer = create(:customer)
      employee = create(:employee)

      certification = CertificationFactory.new.new_instance(
        current_user_id: create(:user, username: 'creator_username', customer: customer).id,
        employee_id: employee.id,
        certification_type_id: certification_type.id
      )

      certification.created_by.should == 'creator_username'
    end
  end
end