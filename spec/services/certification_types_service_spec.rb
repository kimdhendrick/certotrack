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
end
