require 'spec_helper'

describe CertificationTypeService do
  let(:customer) { create(:customer) }
  let(:search_service) { SearchService.new }
  subject { CertificationTypeService.new(search_service: search_service) }

  describe '#create_certification_type' do
    it 'should create certification type' do
      attributes =
        {
          'name' => 'Box',
          'units_required' => '15',
          'interval' => '5 years'
        }
      certification_type = subject.create_certification_type(customer, attributes)

      certification_type.should be_persisted
      certification_type.name.should == 'Box'
      certification_type.units_required.should == 15
      certification_type.interval.should == '5 years'
      certification_type.customer.should == customer
    end
  end

  describe '#update_certification_type' do
    let!(:certification_type) { create(:certification_type, customer: customer) }
    let(:attributes) do
      {
        'name' => 'CPR',
        'interval' => '5 years'
      }
    end

    it 'should return true' do
      subject.update_certification_type(certification_type, attributes).should be_true
    end

    it 'should return false if saving a certification fails' do
      create(:certification, certification_type: certification_type)
      Certification.any_instance.stub(:save).and_return false

      subject.update_certification_type(certification_type, attributes).should be_false
    end

    it 'should update certification_types attributes' do
      subject.update_certification_type(certification_type, attributes)
      certification_type.reload
      certification_type.name.should == 'CPR'
      certification_type.interval.should == '5 years'
    end

    it 'should recalculate expiration date for associated certifications' do
      certification = create(
        :certification,
        certification_type: certification_type,
        last_certification_date: '2012-03-29'.to_date,
        expiration_date: '2000-01-01'.to_date
      )

      subject.update_certification_type(certification_type, attributes)

      certification.reload
      certification.expiration_date.should == '2017-03-29'.to_date
    end

    context 'when errors' do
      before { certification_type.stub(:save).and_return(false) }

      it 'should return false' do
        subject.update_certification_type(certification_type, {}).should be_false
      end
    end
  end

  describe '#delete_certification_type' do
    let!(:certification_type) { create(:certification_type, customer: customer) }

    it 'destroys the requested certification_type' do
      expect {
        subject.delete_certification_type(certification_type)
      }.to change(CertificationType, :count).by(-1)
    end
  end

  describe '#certification_type retrieval' do
    let(:admin_user) { create(:user, admin: true) }
    let(:my_user) { create(:user, customer: customer) }
    let!(:my_certification_type) { create(:certification_type, customer: customer) }
    let!(:other_certification_type) { create(:certification_type) }

    describe '#get_all_certification_types' do
      context 'when an admin user' do
        it 'should return all certification_types' do
          subject.get_all_certification_types(admin_user).should =~ [my_certification_type, other_certification_type]
        end
      end

      context 'when a regular user' do
        it "should return only that user's certification_types" do
          subject.get_all_certification_types(my_user).should == [my_certification_type]
        end
      end
    end

    describe '#search_certification_types' do
      context 'search' do
        let(:search_service) { double('search_service', search: []) }

        it 'should call SearchService to filter results' do
          subject.search_certification_types(my_user, {thing1: 'thing2'})
          expect(search_service).to have_received(:search).with(anything(), {thing1: 'thing2'})
        end
      end

      describe 'authorization' do
        context 'when an admin user' do
          it 'should return all certification_types' do
            subject.search_certification_types(admin_user).should =~ [my_certification_type, other_certification_type]
          end
        end

        context 'when a regular user' do
          it "should return only that user's certification_types" do
            subject.search_certification_types(my_user).should == [my_certification_type]
          end
        end
      end
    end

    describe '#find' do
      context 'when an admin user' do
        it 'should return all certification_types' do
          subject.find([my_certification_type.id, other_certification_type.id], admin_user).should =~ [my_certification_type, other_certification_type]
        end
      end

      context 'when a regular user' do
        it "should return only that user's certification_types" do
          subject.find([my_certification_type.id, other_certification_type.id], my_user).should == [my_certification_type]
        end
      end
    end
  end
end
