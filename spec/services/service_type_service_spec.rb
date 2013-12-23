require 'spec_helper'

describe ServiceTypeService do
  let(:my_customer) { create(:customer) }

  describe '#get_all_service_types' do
    let!(:my_service_type) { create(:service_type, customer: my_customer) }
    let!(:other_service_type) { create(:service_type) }

    context 'when admin user' do
      it 'should return all service_types' do
        admin_user = create(:user, roles: ['admin'])

        service_types = ServiceTypeService.new.get_all_service_types(admin_user)

        service_types.should =~ [my_service_type, other_service_type]
      end
    end

    context 'when regular user' do
      it "should return only customer's service_types" do
        user = create(:user, customer: my_customer)

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

      service_type = subject.create_service_type(my_customer, attributes)

      service_type.should be_persisted
      service_type.name.should == 'Box Check'
      service_type.interval_date.should == '5 years'
      service_type.interval_mileage.should == 50000
      service_type.customer.should == my_customer
    end
  end
end