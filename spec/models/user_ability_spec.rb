require 'spec_helper'
require 'cancan/matchers'

describe User do
  describe 'abilities' do
    subject { ability }
    let(:ability) { Ability.new(user) }
    let(:user) { nil }

    context 'when user is an admin' do
      let(:user) { new_valid_user(roles: ['admin']) }

      it { should be_able_to(:manage, :all) }
    end

    context 'when user is a guest' do
      let(:user) { new_valid_user }

      it { should_not be_able_to(:manage, :all) }
      it { should_not be_able_to(:manage, :equipment) }
      it { should_not be_able_to(:manage, :certification) }
      it { should_not be_able_to(:manage, :vehicle) }
    end

    context 'when user is an equipment user' do
      let(:user) { new_valid_user(roles: ['equipment']) }

      it { should be_able_to(:read, :equipment) }
      it { should be_able_to(:create, :equipment) }
      it { should_not be_able_to(:manage, :all) }
      it { should_not be_able_to(:manage, :certification) }
      it { should_not be_able_to(:manage, :vehicle) }
    end

    context 'when user is an equipment user' do
      let(:user) {
        new_valid_user(roles: ['equipment'], customer: new_valid_customer)
      }
      let(:own_equipment) {
        new_valid_equipment(customer: user.customer)
      }
      let(:other_customer_equipment) {
        new_valid_equipment(customer: new_valid_customer)
      }

      it { should be_able_to(:manage, own_equipment) }
      it { should_not be_able_to(:manage, other_customer_equipment) }
    end

    context 'when user is a certification user' do
      let(:user) { new_valid_user(roles: ['certification']) }

      it { should be_able_to(:manage, :certification) }
      it { should_not be_able_to(:manage, :all) }
      it { should_not be_able_to(:manage, :equipment) }
      it { should_not be_able_to(:manage, :vehicle) }
    end

    context 'when user is a vehicle user' do
      let(:user) { new_valid_user(roles: ['vehicle']) }

      it { should be_able_to(:manage, :vehicle) }
      it { should_not be_able_to(:manage, :all) }
      it { should_not be_able_to(:manage, :equipment) }
      it { should_not be_able_to(:manage, :certification) }
    end
  end
end