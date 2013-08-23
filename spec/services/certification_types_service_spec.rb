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

      certification_type.name.should == 'Box'
      certification_type.units_required.should == 15
      certification_type.interval.should == '5 years'
      certification_type.customer.should == customer
    end
  end
end
