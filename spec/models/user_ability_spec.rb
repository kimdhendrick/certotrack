require 'spec_helper'
require 'cancan/matchers'

describe User do
  describe 'abilities' do
    subject { ability }
    let(:ability) { Ability.new(user) }
    let(:user) { nil }

    context 'when user is an admin' do
      let(:user) { build(:user, roles: ['admin']) }

      it { should be_able_to(:manage, :all) }
    end

    context 'when user is a guest' do
      let(:user) { build(:user) }

      it { should_not be_able_to(:manage, :all) }
      it { should_not be_able_to(:manage, :equipment) }
      it { should_not be_able_to(:manage, :certification) }
      it { should_not be_able_to(:manage, :vehicle) }
    end

    context 'when user is an equipment user' do
      let(:user) { build(:user, roles: ['equipment']) }

      it { should be_able_to(:read, :equipment) }
      it { should be_able_to(:create, :equipment) }
      it { should_not be_able_to(:manage, :all) }
      it { should_not be_able_to(:manage, :certification) }
      it { should_not be_able_to(:manage, :vehicle) }
    end

    context 'when user is an equipment user with equipment' do
      let(:user) {
        build(:user, roles: ['equipment'])
      }
      let(:own_equipment) {
        build(:equipment, customer: user.customer)
      }
      let(:other_customer_equipment) {
        build(:equipment)
      }

      it { should be_able_to(:manage, own_equipment) }
      it { should_not be_able_to(:manage, other_customer_equipment) }
    end

    context 'when user is a certification user' do
      let(:user) { build(:user, roles: ['certification']) }

      it { should be_able_to(:read, :certification) }
      it { should be_able_to(:create, :certification) }
      it { should_not be_able_to(:manage, :all) }
      it { should_not be_able_to(:manage, :equipment) }
      it { should_not be_able_to(:manage, :vehicle) }
    end

    context 'when user is an certification user with certification types' do
      let(:user) {
        build(:user, roles: ['certification'])
      }
      let(:own_certification_type) {
        build(:certification_type, customer: user.customer)
      }
      let(:other_customer_certification_type) {
        build(:certification_type)
      }

      it { should be_able_to(:manage, own_certification_type) }
      it { should_not be_able_to(:manage, other_customer_certification_type) }
    end

    context 'when user is a certification user with employee' do
      let(:user) {
        build(:user, roles: ['certification'])
      }
      let(:own_employee) {
        build(:employee, customer: user.customer)
      }
      let(:other_employee) {
        build(:employee)
      }

      it { should be_able_to(:manage, own_employee) }
      it { should_not be_able_to(:manage, other_employee) }
    end

    context 'when user is a vehicle user' do
      let(:user) { build(:user, roles: ['vehicle']) }

      it { should be_able_to(:read, :vehicle) }
      it { should be_able_to(:create, :vehicle) }
      it { should_not be_able_to(:manage, :all) }
      it { should_not be_able_to(:manage, :equipment) }
      it { should_not be_able_to(:manage, :certification) }
    end
  end
end