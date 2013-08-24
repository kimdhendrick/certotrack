require 'spec_helper'

describe CertificationTypesService do
  describe 'create_certification_type' do
    it 'should create certification type' do
      attributes =
        {
          'name' => 'Box',
          'units_required' => '15',
          'interval' => '5 years'
        }
      customer = new_customer

      certification_type = CertificationTypesService.new.create_certification_type(customer, attributes)

      certification_type.should be_persisted
      certification_type.name.should == 'Box'
      certification_type.units_required.should == 15
      certification_type.interval.should == '5 years'
      certification_type.customer.should == customer
    end
  end

  describe 'update_certification_type' do
    it 'should update certification_types attributes' do
      certification_type = create_certification_type(name: 'Certification', customer: @customer)
      attributes =
        {
          'id' => certification_type.id,
          'name' => 'CPR',
          'interval' => '5 years',
          'units_required' => '1009'
        }

      success = CertificationTypesService.new.update_certification_type(certification_type, attributes)
      success.should be_true

      certification_type.reload
      certification_type.name.should == 'CPR'
      certification_type.interval.should == '5 years'
    end

    it 'should return false if errors' do
      certification_type = create_certification_type(name: 'Certification', customer: @customer)
      certification_type.stub(:save).and_return(false)

      success = CertificationTypesService.new.update_certification_type(certification_type, {})
      success.should be_false

      certification_type.reload
      certification_type.name.should_not == 'CPR'
    end
  end

  describe 'delete_certification_type' do
    it 'destroys the requested certification_type' do
      certification_type = create_certification_type(customer: @customer)

      expect {
        CertificationTypesService.new.delete_certification_type(certification_type)
      }.to change(CertificationType, :count).by(-1)
    end
  end

  describe 'get_all_certification_types' do
    before do
      @my_customer = create_customer
      @my_user = create_user(customer: @my_customer)
    end

    context 'sorting' do
      it 'should call SortService to ensure sorting' do
        certification_types_service = CertificationTypesService.new
        fake_sort_service = certification_types_service.load_sort_service(FakeService.new([]))

        certification_types_service.get_all_certification_types(@my_user)

        fake_sort_service.received_message.should == :sort
      end
    end

    context 'pagination' do
      it 'should call PaginationService to paginate results' do
        certification_types_service = CertificationTypesService.new
        certification_types_service.load_sort_service(FakeService.new)
        fake_pagination_service = certification_types_service.load_pagination_service(FakeService.new)

        certification_types_service.get_all_certification_types(@my_user)

        fake_pagination_service.received_message.should == :paginate
      end
    end

    context 'an admin user' do
      it 'should return all certification_types' do
        my_certification_type = create_certification_type(customer: @my_customer)
        other_certification_type = create_certification_type(customer: create_customer)

        admin_user = create_user(roles: ['admin'])

        CertificationTypesService.new.get_all_certification_types(admin_user).should == [my_certification_type, other_certification_type]
      end
    end

    context 'a regular user' do
      it "should return only that user's certification_types" do
        my_certification_type = create_certification_type(customer: @my_customer)
        other_certification_type = create_certification_type(customer: create_customer)

        CertificationTypesService.new.get_all_certification_types(@my_user).should == [my_certification_type]
      end
    end
  end
end
