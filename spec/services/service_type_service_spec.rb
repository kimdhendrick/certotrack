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
end