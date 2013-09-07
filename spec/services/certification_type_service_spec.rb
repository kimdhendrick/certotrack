require 'spec_helper'

describe CertificationTypeService do
  before do
    @customer = create(:customer)
  end

  describe 'create_certification_type' do
    it 'should create certification type' do
      attributes =
        {
          'name' => 'Box',
          'units_required' => '15',
          'interval' => '5 years'
        }
      customer = build(:customer)

      certification_type = CertificationTypeService.new.create_certification_type(customer, attributes)

      certification_type.should be_persisted
      certification_type.name.should == 'Box'
      certification_type.units_required.should == 15
      certification_type.interval.should == '5 years'
      certification_type.customer.should == customer
    end
  end

  describe 'update_certification_type' do
    it 'should update certification_types attributes' do
      certification_type = create(:certification_type, name: 'Certification', customer: @customer)
      attributes =
        {
          'id' => certification_type.id,
          'name' => 'CPR',
          'interval' => '5 years',
          'units_required' => '1009'
        }

      success = CertificationTypeService.new.update_certification_type(certification_type, attributes)
      success.should be_true

      certification_type.reload
      certification_type.name.should == 'CPR'
      certification_type.interval.should == '5 years'
    end

    it 'should return false if errors' do
      certification_type = create(:certification_type, name: 'Certification', customer: @customer)
      certification_type.stub(:save).and_return(false)

      success = CertificationTypeService.new.update_certification_type(certification_type, {})
      success.should be_false

      certification_type.reload
      certification_type.name.should_not == 'CPR'
    end
  end

  describe 'delete_certification_type' do
    it 'destroys the requested certification_type' do
      certification_type = create(:certification_type, customer: @customer)

      expect {
        CertificationTypeService.new.delete_certification_type(certification_type)
      }.to change(CertificationType, :count).by(-1)
    end
  end

  describe 'get_all_certification_types' do
    before do
      @my_customer = create(:customer)
      @my_user = create(:user, customer: @my_customer)
    end

    context 'an admin user' do
      it 'should return all certification_types' do
        my_certification_type = create(:certification_type, customer: @my_customer)
        other_certification_type = create(:certification_type)

        admin_user = create(:user, roles: ['admin'])

        CertificationTypeService.new.get_all_certification_types(admin_user).should == [my_certification_type, other_certification_type]
      end
    end

    context 'a regular user' do
      it "should return only that user's certification_types" do
        my_certification_type = create(:certification_type, customer: @my_customer)
        other_certification_type = create(:certification_type)

        CertificationTypeService.new.get_all_certification_types(@my_user).should == [my_certification_type]
      end
    end
  end

  describe 'get_certification_type_list' do
    before do
      @my_customer = create(:customer)
      @my_user = create(:user, customer: @my_customer)
    end

    context 'sorting' do
      it 'should call SortService to ensure sorting' do
        fake_sort_service = FakeService.new([])
        certification_type_service = CertificationTypeService.new(sort_service: fake_sort_service)

        certification_type_service.get_certification_type_list(@my_user)

        fake_sort_service.received_message.should == :sort
      end
    end

    context 'pagination' do
      it 'should call PaginationService to paginate results' do
        fake_pagination_service = FakeService.new
        certification_type_service = CertificationTypeService.new(sort_service: FakeService.new, pagination_service: fake_pagination_service)

        certification_type_service.get_certification_type_list(@my_user)

        fake_pagination_service.received_message.should == :paginate
      end
    end

    context 'search' do
      it 'should call SearchService to filter results' do
        fake_search_service = FakeService.new([])
        certification_type_service = CertificationTypeService.new(sort_service: FakeService.new([]), search_service: fake_search_service)

        certification_type_service.get_certification_type_list(@my_user, {thing1: 'thing2'})

        fake_search_service.received_message.should == :search
        fake_search_service.received_params[0].should == []
        fake_search_service.received_params[1].should == {thing1: 'thing2'}
      end
    end

    context 'an admin user' do
      it 'should return all certification_types' do
        my_certification_type = create(:certification_type, customer: @my_customer)
        other_certification_type = create(:certification_type)

        admin_user = create(:user, roles: ['admin'])

        CertificationTypeService.new.get_certification_type_list(admin_user).should =~ [my_certification_type, other_certification_type]
      end
    end

    context 'a regular user' do
      it "should return only that user's certification_types" do
        my_certification_type = create(:certification_type, customer: @my_customer)
        other_certification_type = create(:certification_type)

        CertificationTypeService.new.get_certification_type_list(@my_user).should == [my_certification_type]
      end
    end
  end
end
