require 'spec_helper'

module Export
  describe PdfCollectionPresenter do
    describe '#collection' do
      let(:params) { {key: 'value'} }
      let(:list_presenter) { double(:list_presenter) }
      let(:sorted_collection) { double(:sorted_collection) }

      describe 'users' do
        let(:collection) { [User.new] }

        it 'should wrap models in presenters' do
          allow(UserListPresenter).to receive(:new).with(collection).and_return(list_presenter)
          expect(list_presenter).to receive(:sort).with(params).and_return(sorted_collection)

          results = described_class.new(collection, params).collection

          expect(results).to eq(sorted_collection)
        end
      end

      describe 'equipment' do
        let(:collection) { [Equipment.new] }

        it 'should wrap models in presenters' do
          allow(EquipmentListPresenter).to receive(:new).with(collection).and_return(list_presenter)
          expect(list_presenter).to receive(:sort).with(params).and_return(sorted_collection)

          results = described_class.new(collection, params).collection

          expect(results).to eq(sorted_collection)
        end
      end

      describe 'certifications' do
        let(:collection) { [Certification.new] }

        it 'should wrap models in presenters' do
          allow(CertificationListPresenter).to receive(:new).with(collection).and_return(list_presenter)
          expect(list_presenter).to receive(:sort).with(params).and_return(sorted_collection)

          results = described_class.new(collection, params).collection

          expect(results).to eq(sorted_collection)
        end
      end

      describe 'employees' do
        let(:collection) { [Employee.new] }

        it 'should wrap models in presenters' do
          allow(EmployeeListPresenter).to receive(:new).with(collection).and_return(list_presenter)
          expect(list_presenter).to receive(:sort).with(params).and_return(sorted_collection)

          results = described_class.new(collection, params).collection

          expect(results).to eq(sorted_collection)
        end
      end

      describe 'customers' do
        let(:collection) { [Customer.new] }

        it 'should wrap models in presenters' do
          allow(CustomerListPresenter).to receive(:new).with(collection).and_return(list_presenter)
          expect(list_presenter).to receive(:sort).with(params).and_return(sorted_collection)

          results = described_class.new(collection, params).collection

          expect(results).to eq(sorted_collection)
        end
      end
    end
  end
end