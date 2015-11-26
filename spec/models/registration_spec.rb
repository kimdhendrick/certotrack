require 'spec_helper'

describe Registration do
  describe 'validations' do
    it { should validate_presence_of :customer_name }
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    it { should validate_presence_of :email }
    it { should validate_presence_of :subscription }

    it 'should validate subscription value' do
      registration = Registration.new(subscription: 'bogus')
      registration.should_not be_valid
      registration.errors[:subscription].should == ['invalid value']
    end

    it 'should validate the passwords match' do
      registration = Registration.new(password: 'Password123!', password_confirm: 'something else!')

      registration.should_not be_valid
      registration.errors[:password].should == ['does not match Confirm Password']

      registration = Registration.new(password: 'Password123!', password_confirm: 'Password123!')
      registration.errors[:password].should == []
    end
  end
end