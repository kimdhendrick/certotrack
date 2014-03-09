require 'spec_helper'

describe CertificationService do
  describe '#count_all_certifications' do
    let(:my_customer) { create(:customer) }
    before do
      certification_one = create(:certification, customer: my_customer)
      certification_two = create(:certification)
    end

    context 'an admin user' do
      it 'should return count that includes all certifications' do
        admin_user = create(:user, admin: true)

        CertificationService.new.count_all_certifications(admin_user).should == 2
      end
    end

    context 'a regular user' do
      it "should return count that includes only that user's certifications" do
        user = create(:user, customer: my_customer)

        CertificationService.new.count_all_certifications(user).should == 1
      end
    end
  end

  describe '#count_expired_certifications' do
    let(:my_customer) { create(:customer) }
    before do
      certification_one_expired = create(:certification, customer: my_customer, expiration_date: Date.yesterday)
      certification_one_valid = create(:certification, customer: my_customer, expiration_date: Date.tomorrow)
      certification_two_expired = create(:certification, expiration_date: Date.yesterday)
      certification_two_valid = create(:certification, expiration_date: Date.tomorrow)
    end

    context 'an admin user' do
      it 'should return count that includes all expired certifications' do
        admin_user = create(:user, admin: true)

        CertificationService.new.count_expired_certifications(admin_user).should == 2
      end
    end

    context 'a regular user' do
      it "should return count that includes only that user's expired certifications" do
        user = create(:user, customer: my_customer)

        CertificationService.new.count_expired_certifications(user).should == 1
      end
    end
  end

  describe '#count_expiring_certifications' do
    let(:my_customer) { create(:customer) }
    before do
      certification_one_expiring = create(:certification, customer: my_customer, expiration_date: Date.yesterday)
      certification_one_valid = create(:certification, customer: my_customer, expiration_date: Date.tomorrow)
      certification_two_expiring = create(:certification, expiration_date: Date.yesterday)
      certification_two_valid = create(:certification, expiration_date: Date.tomorrow)
    end

    context 'an admin user' do
      it 'should return count that includes all expiring certifications' do
        admin_user = create(:user, admin: true)

        CertificationService.new.count_expiring_certifications(admin_user).should == 2
      end
    end

    context 'a regular user' do
      it "should return count that includes only that user's expiring certifications" do
        user = create(:user, customer: my_customer)

        CertificationService.new.count_expiring_certifications(user).should == 1
      end
    end
  end

  describe '#count_units_based_certifications' do
    let(:my_customer) { create(:customer) }
    before do
      units_based_certification_for_my_customer = create(:units_based_certification, customer: my_customer, expiration_date: Date.yesterday)
      date_based_certification_for_my_customer = create(:certification, customer: my_customer, expiration_date: Date.tomorrow)
      units_based_certification_for_other_customer = create(:units_based_certification, expiration_date: Date.yesterday)
      date_based_certification_for_other_customer = create(:certification, expiration_date: Date.tomorrow)
    end

    context 'an admin user' do
      it 'should return count that includes all units based certifications' do
        admin_user = create(:user, admin: true)

        CertificationService.new.count_units_based_certifications(admin_user).should == 2
      end
    end

    context 'a regular user' do
      it "should return count that includes only that user's units based certifications" do
        user = create(:user, customer: my_customer)

        CertificationService.new.count_units_based_certifications(user).should == 1
      end
    end
  end

  describe '#count_recertification_required_certifications' do
    let(:my_customer) { create(:customer) }
    before do
      certification_type = create(:units_based_certification_type, units_required: 1)
      recertify_certification_for_my_customer = create(:units_based_certification, customer: my_customer, certification_type: certification_type, units_achieved: 0)
      valid_certification_for_my_customer = create(:certification, customer: my_customer, certification_type: certification_type, units_achieved: 1)
      recertify_certification_for_other_customer = create(:units_based_certification, certification_type: certification_type, units_achieved: 0)
      valid_certification_for_other_customer = create(:certification, certification_type: certification_type, units_achieved: 1)
    end

    context 'an admin user' do
      it 'should return count that includes all units based certifications' do
        admin_user = create(:user, admin: true)

        CertificationService.new.count_recertification_required_certifications(admin_user).should == 2
      end
    end

    context 'a regular user' do
      it "should return count that includes only that user's units based certifications" do
        user = create(:user, customer: my_customer)

        CertificationService.new.count_recertification_required_certifications(user).should == 1
      end
    end
  end

  describe '#get_all_certifications' do
    let(:my_customer) { create(:customer) }

    context 'an admin user' do
      it 'should return all certifications' do
        admin_user = create(:user, admin: true)

        my_certification = create(:certification, customer: my_customer)
        other_certification = create(:certification)

        CertificationService.new.get_all_certifications(admin_user).should == [my_certification, other_certification]
      end
    end

    context 'a regular user' do
      it "should return only that user's certifications" do
        my_user = create(:user, customer: my_customer)

        my_certification = create(:certification, customer: my_customer)
        other_certification = create(:certification)

        CertificationService.new.get_all_certifications(my_user).should == [my_certification]
      end
    end
  end

  describe '#get_expired_certifications' do
    let(:my_customer) { create(:customer) }
    let!(:certification_one_expired) { create(:certification, customer: my_customer, expiration_date: Date.yesterday) }
    let!(:certification_one_valid) { create(:certification, customer: my_customer, expiration_date: Date.tomorrow) }
    let!(:certification_two_expired) { create(:certification, expiration_date: Date.yesterday) }
    let!(:certification_two_valid) { create(:certification, expiration_date: Date.tomorrow) }

    context 'an admin user' do
      it 'should return count that includes all expired certifications' do
        admin_user = create(:user, admin: true)

        CertificationService.new.get_expired_certifications(admin_user).should =~
            [certification_one_expired, certification_two_expired]
      end
    end

    context 'a regular user' do
      it "should return count that includes only that user's expired certifications" do
        user = create(:user, customer: my_customer)

        CertificationService.new.get_expired_certifications(user).should == [certification_one_expired]
      end
    end
  end

  describe '#get_expiring_certifications' do
    let(:my_customer) { create(:customer) }
    let!(:certification_one_expiring) { create(:certification, customer: my_customer, expiration_date: Date.tomorrow) }
    let!(:certification_one_expired) { create(:certification, customer: my_customer, expiration_date: Date.today) }
    let!(:certification_two_expiring) { create(:certification, expiration_date: Date.tomorrow) }
    let!(:certification_two_expired) { create(:certification, expiration_date: Date.today) }

    context 'an admin user' do
      it 'should return count that includes all expiring certifications' do
        admin_user = create(:user, admin: true)

        CertificationService.new.get_expiring_certifications(admin_user).should =~
            [certification_one_expiring, certification_two_expiring]
      end
    end

    context 'a regular user' do
      it "should return count that includes only that user's expiring certifications" do
        user = create(:user, customer: my_customer)

        CertificationService.new.get_expiring_certifications(user).should == [certification_one_expiring]
      end
    end
  end

  describe '#get_units_based_certifications' do
    let(:my_customer) { create(:customer) }
    before do
      @units_based_certification_for_my_customer = create(:units_based_certification, customer: my_customer, expiration_date: Date.yesterday)
      @date_based_certification_for_my_customer = create(:certification, customer: my_customer, expiration_date: Date.tomorrow)
      @units_based_certification_for_other_customer = create(:units_based_certification, expiration_date: Date.yesterday)
      @date_based_certification_for_other_customer = create(:certification, expiration_date: Date.tomorrow)
    end

    context 'an admin user' do
      it 'should return count that includes all units based certifications' do
        admin_user = create(:user, admin: true)

        CertificationService.new.get_units_based_certifications(admin_user).should =~
            [@units_based_certification_for_my_customer, @units_based_certification_for_other_customer]
      end
    end

    context 'a regular user' do
      it "should return count that includes only that user's units based certifications" do
        user = create(:user, customer: my_customer)

        CertificationService.new.get_units_based_certifications(user).should == [@units_based_certification_for_my_customer]
      end
    end
  end

  describe '#get_recertification_required_certifications' do
    let(:my_customer) { create(:customer) }
    before do
      certification_type = create(:units_based_certification_type, units_required: 1)
      @recertify_certification_for_my_customer = create(:units_based_certification, customer: my_customer, certification_type: certification_type, units_achieved: 0)
      @valid_certification_for_my_customer = create(:certification, customer: my_customer, certification_type: certification_type, units_achieved: 1)
      @recertify_certification_for_other_customer = create(:units_based_certification, certification_type: certification_type, units_achieved: 0)
      @valid_certification_for_other_customer = create(:certification, certification_type: certification_type, units_achieved: 1)
    end

    context 'an admin user' do
      it 'should return count that includes all units based certifications' do
        admin_user = create(:user, admin: true)

        CertificationService.new.get_recertification_required_certifications(admin_user).should =~
            [@recertify_certification_for_my_customer, @recertify_certification_for_other_customer]
      end
    end

    context 'a regular user' do
      it "should return count that includes only that user's units based certifications" do
        user = create(:user, customer: my_customer)

        CertificationService.new.get_recertification_required_certifications(user).should == [@recertify_certification_for_my_customer]
      end
    end
  end

  describe '#new_certification' do
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

  describe '#certify' do
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

  describe '#delete_certification' do
    it 'destroys the requested certification' do
      certification = create(:certification)
      CertificationPeriod.count.should > 0

      expect {
        CertificationService.new.delete_certification(certification)
      }.to change(Certification, :count).by(-1)

      CertificationPeriod.count.should == 0
    end
  end

  describe '#recertify' do

    subject { CertificationService.new }

    let(:certification) { create(:certification) }
    let(:recertification_attrs) { {} }

    before do
      certification.stub(:recertify)
    end

    it 'should return true is recertification was successful' do
      subject.recertify(certification, recertification_attrs).should be_true
    end

    it 'should return false is recertification was unsuccessful' do
      certification.stub(:valid?).and_return(false)
      subject.recertify(certification, recertification_attrs).should be_false
    end

    it 'should delegate recertification to the certification' do
      certification.should_receive(:recertify).with(recertification_attrs)
      subject.recertify(certification, recertification_attrs)
    end
  end

  describe '#auto_recertify' do
    let(:service) { CertificationService.new }

    describe 'transactional behavior' do

      let(:certification1) { create(:certification) }
      let(:certification2) { create(:certification) }
      let(:certifications) { [certification1, certification2] }

      before { certifications.each { |certification| certification.update_attribute(:expiration_date, Date.current) } }

      it 'should create new certification periods' do
        expect { service.auto_recertify(certifications) }.to change(CertificationPeriod, :count).by(2)
      end

      it 'should be atomic for multiple certifications' do
        Certification.stub(:find).with(certification1.id).and_return(certification1)
        Certification.stub(:find).with(certification2.id).and_return(certification2)

        certification2.stub(:save).and_return(false)

        expect { service.auto_recertify(certifications) }.not_to change(CertificationPeriod, :count)
      end
    end

    describe 'other behavior' do

      let(:certification) { double('certification', id: 1).as_null_object }

      before { Certification.stub(:find).and_return(certification) }

      it 'should return success' do
        certifications = [certification]

        result = service.auto_recertify(certifications)

        result.should == :success
      end

      it 'should create a new certification_period for the certification' do
        previous_expiration_date = Date.current

        certification.stub(:trainer).and_return('trainer')
        certification.stub(:expiration_date).and_return(previous_expiration_date)

        certification.should_receive(:recertify).with(start_date: previous_expiration_date, trainer: 'trainer')

        service.auto_recertify([certification])
      end

      it 'should return failure when transaction fails' do
        certification.stub(:save).and_return(false)

        result = service.auto_recertify([certification])

        result.should == :failure
      end
    end
  end

  describe 'search_certifications' do
    let(:my_customer) { create(:customer) }
    let(:my_user) { create(:user, customer: my_customer) }

    context 'search' do
      it 'should call SearchService to filter results' do
        fake_search_service = Faker.new
        certifications_service = CertificationService.new(search_service: fake_search_service)

        certifications_service.search_certifications(my_user, {thing1: 'thing2'})

        fake_search_service.received_message.should == :search
        fake_search_service.received_params[0].should == []
        fake_search_service.received_params[1].should == {thing1: 'thing2'}
      end
    end

    context 'an admin user' do
      it 'should return all certifications' do
        admin_user = create(:user, admin: true)
        my_certifications = create(:certification, customer: my_customer)
        other_certifications = create(:certification)

        CertificationService.new.search_certifications(admin_user, {}).should == [my_certifications, other_certifications]
      end
    end

    context 'a regular user' do
      it "should return only that user's certifications" do
        my_certifications = create(:certification, customer: my_customer)
        other_certifications = create(:certification)

        CertificationService.new.search_certifications(my_user, {}).should == [my_certifications]
      end
    end
  end
end