require 'spec_helper'
require 'cancan/matchers'

describe User do
  describe 'abilities' do
    subject { ability }
    let(:ability) { Ability.new(user) }
    let(:user) { nil }

    context 'when user is an admin' do
      let(:user) { build(:user, admin: true) }

      it { should be_able_to(:manage, :customer) }
      it { should be_able_to(:manage, :user) }
      it { should be_able_to(:manage, :equipment) }
      it { should be_able_to(:manage, :certification) }
      it { should be_able_to(:manage, :certification_type) }
      it { should be_able_to(:manage, :employee) }
      it { should be_able_to(:manage, :location) }
      it { should be_able_to(:manage, :vehicle) }
      it { should be_able_to(:manage, :service_type) }
      it { should be_able_to(:manage, :service) }
      it { should be_able_to(:manage, :administration) }
    end

    context 'when user is a guest' do
      let(:user) { build(:user) }

      it { should_not be_able_to(:manage, :all) }
      it { should_not be_able_to(:manage, :equipment) }
      it { should_not be_able_to(:manage, :certification) }
      it { should_not be_able_to(:manage, :certification_type) }
      it { should_not be_able_to(:manage, :employee) }
      it { should_not be_able_to(:manage, :location) }
      it { should_not be_able_to(:manage, :vehicle) }
      it { should_not be_able_to(:manage, :customer) }
      it { should_not be_able_to(:manage, :user) }
      it { should_not be_able_to(:manage, :service_type) }
      it { should_not be_able_to(:manage, :service) }
    end

    context 'when user is an equipment user' do
      let(:user) { build(:user, roles: ['equipment']) }

      it { should be_able_to(:read, :equipment) }
      it { should be_able_to(:create, :equipment) }
      it { should be_able_to(:read, :location) }
      it { should be_able_to(:create, :location) }
      it { should be_able_to(:read, :employee) }
      it { should be_able_to(:create, :employee) }
      it { should_not be_able_to(:read, :vehicle) }
      it { should_not be_able_to(:read, :certification) }
      it { should_not be_able_to(:read, :certification_type) }
      it { should_not be_able_to(:manage, :customer) }
      it { should_not be_able_to(:manage, :user) }
      it { should_not be_able_to(:manage, :service_type) }
      it { should_not be_able_to(:manage, :service) }
    end

    context 'when user is an equipment user with equipment' do
      let(:user) { build(:user, roles: ['equipment']) }
      let(:own_equipment) { build(:equipment, customer: user.customer) }
      let(:other_customer_equipment) { build(:equipment) }

      it { should be_able_to(:manage, own_equipment) }
      it { should_not be_able_to(:manage, other_customer_equipment) }
    end

    context 'when user is a equipment user with employee' do
      let(:user) { build(:user, roles: ['equipment']) }
      let(:own_employee) { build(:employee, customer: user.customer) }
      let(:other_employee) { build(:employee) }

      it { should be_able_to(:manage, own_employee) }
      it { should_not be_able_to(:manage, other_employee) }
    end

    context 'when user is an equipment user with locations' do
      let(:user) { build(:user, roles: ['equipment']) }
      let(:own_location) { build(:location, customer: user.customer) }
      let(:other_customer_location) { build(:location) }

      it { should be_able_to(:manage, own_location) }
      it { should_not be_able_to(:manage, other_customer_location) }
    end

    context 'when user is a certification user' do
      let(:user) { build(:user, roles: ['certification']) }

      it { should be_able_to(:read, :certification) }
      it { should be_able_to(:create, :certification) }
      it { should be_able_to(:read, :certification_type) }
      it { should be_able_to(:create, :certification_type) }
      it { should be_able_to(:read, :location) }
      it { should be_able_to(:create, :location) }
      it { should be_able_to(:read, :employee) }
      it { should_not be_able_to(:manage, :equipment) }
      it { should_not be_able_to(:read, :vehicle) }
      it { should_not be_able_to(:manage, :customer) }
      it { should_not be_able_to(:manage, :user) }
      it { should_not be_able_to(:manage, :service_type) }
      it { should_not be_able_to(:manage, :service) }

    end

    context 'when user is an certification user with certification types' do
      let(:user) { build(:user, roles: ['certification']) }
      let(:own_certification_type) { build(:certification_type, customer: user.customer) }
      let(:other_customer_certification_type) { build(:certification_type) }

      it { should be_able_to(:manage, own_certification_type) }
      it { should_not be_able_to(:manage, other_customer_certification_type) }
    end

    context 'when user is an certification user with certifications' do
      let(:user) { build(:user, roles: ['certification']) }
      let(:own_certification) { build(:certification, customer: user.customer) }
      let(:other_customer_certification) { build(:certification) }

      it { should be_able_to(:manage, own_certification) }
      it { should_not be_able_to(:manage, other_customer_certification) }
    end

    context 'when user is a certification user with employee' do
      let(:user) { build(:user, roles: ['certification']) }
      let(:own_employee) { build(:employee, customer: user.customer) }
      let(:other_employee) { build(:employee) }

      it { should be_able_to(:manage, own_employee) }
      it { should_not be_able_to(:manage, other_employee) }
    end

    context 'when user is an certification user with locations' do
      let(:user) { build(:user, roles: ['certification']) }
      let(:own_location) { build(:location, customer: user.customer) }
      let(:other_customer_location) { build(:location) }

      it { should be_able_to(:manage, own_location) }
      it { should_not be_able_to(:manage, other_customer_location) }
    end

    context 'when user is a vehicle user' do
      let(:user) { build(:user, roles: ['vehicle']) }

      it { should be_able_to(:read, :vehicle) }
      it { should be_able_to(:create, :vehicle) }
      it { should be_able_to(:read, :location) }
      it { should be_able_to(:create, :location) }
      it { should be_able_to(:create, :service_type) }
      it { should be_able_to(:create, :service) }
      it { should_not be_able_to(:read, :equipment) }
      it { should_not be_able_to(:read, :certification) }
      it { should_not be_able_to(:read, :certification_type) }
      it { should_not be_able_to(:read, :employee) }
      it { should_not be_able_to(:manage, :customer) }
      it { should_not be_able_to(:manage, :user) }
    end

    context 'when user is an vehicle user with vehicle' do
      let(:user) { build(:user, roles: ['vehicle']) }
      let(:own_vehicle) { build(:vehicle, customer: user.customer) }
      let(:other_customer_vehicle) { build(:vehicle) }

      it { should be_able_to(:manage, own_vehicle) }
      it { should_not be_able_to(:manage, other_customer_vehicle) }
    end

    context 'when user is an vehicle user with service_type' do
      let(:user) { build(:user, roles: ['vehicle']) }
      let(:own_service_type) { build(:service_type, customer: user.customer) }
      let(:other_customer_service_type) { build(:service_type) }

      it { should be_able_to(:manage, own_service_type) }
      it { should_not be_able_to(:manage, other_customer_service_type) }
    end

    context 'when user is an vehicle user with service' do
      let(:user) { build(:user, roles: ['vehicle']) }
      let(:own_service) { build(:service, customer: user.customer) }
      let(:other_customer_service) { build(:service) }

      it { should be_able_to(:manage, own_service) }
      it { should_not be_able_to(:manage, other_customer_service) }
    end
  end
end