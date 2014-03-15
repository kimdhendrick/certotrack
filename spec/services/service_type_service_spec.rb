require 'spec_helper'

describe ServiceTypeService do
  let(:customer) { create(:customer) }

  describe '#get_all_service_types' do
    let!(:my_service_type) { create(:service_type, customer: customer) }
    let!(:other_service_type) { create(:service_type) }

    context 'when admin user' do
      it 'should return all service_types' do
        admin_user = create(:user, admin: true)

        service_types = ServiceTypeService.new.get_all_service_types(admin_user)

        service_types.should =~ [my_service_type, other_service_type]
      end
    end

    context 'when regular user' do
      it "should return only customer's service_types" do
        user = create(:user, customer: customer)

        service_types = ServiceTypeService.new.get_all_service_types(user)

        service_types.should == [my_service_type]
      end
    end
  end

  describe '#create_service_type' do
    it 'should create service type' do
      attributes =
        {
          'name' => 'Box Check',
          'expiration_type' => ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE,
          'interval_date' => '5 years',
          'interval_mileage' => '50000'
        }

      service_type = subject.create_service_type(customer, attributes)

      service_type.should be_persisted
      service_type.name.should == 'Box Check'
      service_type.interval_date.should == '5 years'
      service_type.interval_mileage.should == 50000
      service_type.customer.should == customer
    end
  end

  describe '#update_service_type' do
    let!(:service_type) { create(:service_type, customer: customer) }
    let(:attributes) do
      {
        'name' => 'Transmission flush',
        'expiration_type' => ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE,
        'interval_date' => '5 years',
        'interval_mileage' => 20000
      }
    end

    it 'should return true' do
      subject.update_service_type(service_type, attributes).should be_true
    end

    it 'should update service_types attributes' do
      subject.update_service_type(service_type, attributes)
      service_type.reload
      service_type.name.should == 'Transmission flush'
      service_type.interval_date.should == '5 years'
      service_type.interval_mileage.should == 20000
      service_type.expiration_type.should == ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE
    end

    it 'should return false if one of the serve updates fails' do
      create(:service, service_type: service_type)
      Service.any_instance.stub(:save).and_return(false)

      subject.update_service_type(service_type, attributes).should be_false
    end

    it 'should recalculate expiration date for associated services' do
      service = create(
        :service,
        service_type: service_type,
        last_service_date: '2012-03-29'.to_date,
        expiration_date: '2000-01-01'.to_date,
        last_service_mileage: 1000,
        expiration_mileage: 2000
      )

      subject.update_service_type(service_type, attributes)

      service.reload
      service.expiration_date.should == '2017-03-29'.to_date
      service.expiration_mileage.should == 21000
    end

    context 'when errors' do
      before { service_type.stub(:save).and_return(false) }

      it 'should return false' do
        subject.update_service_type(service_type, {}).should be_false
      end
    end
  end

  describe '#delete_service_type' do
    let!(:service_type) { create(:service_type, customer: customer) }
    it 'destroys the requested service_type' do
      expect {
        subject.delete_service_type(service_type)
      }.to change(ServiceType, :count).by(-1)
    end
  end
end