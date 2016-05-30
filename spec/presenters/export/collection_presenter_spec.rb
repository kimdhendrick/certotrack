require 'spec_helper'

module Export
  describe CollectionPresenter do
    describe '#collection' do
      describe 'users' do
        let(:collection) { [User.new] }

        it 'should wrap models in presenters' do
          results = described_class.new(collection, nil).collection

          expect(results.first).to be_a UserPresenter
        end
      end

      describe 'equipment' do
        let(:collection) { [Equipment.new] }

        it 'should wrap models in presenters' do
          results = described_class.new(collection, nil).collection

          expect(results.first).to be_a EquipmentPresenter
        end
      end

      describe 'certifications' do
        let(:collection) { [Certification.new] }

        it 'should wrap models in presenters' do
          results = described_class.new(collection, nil).collection

          expect(results.first).to be_a CertificationPresenter
        end
      end

      describe 'employees' do
        let(:collection) { [Employee.new] }

        it 'should wrap models in presenters' do
          results = described_class.new(collection, nil).collection

          expect(results.first).to be_a EmployeePresenter
        end
      end

      describe 'customers' do
        let(:collection) { [Customer.new] }

        it 'should wrap models in presenters' do
          results = described_class.new(collection, nil).collection

          expect(results.first).to be_a CustomerPresenter
        end
      end
    end
  end
end