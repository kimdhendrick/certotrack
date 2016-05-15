require 'spec_helper'

module Export
  describe CollectionExporter do
    let(:equipment) { Equipment.new }
    let(:equipment_collection) { [equipment] }
    let(:collection_wrapper) { double(:collection_wrapper, collection: []) }

    describe '#headers' do
      context 'when equipment' do
        let(:collection) { [equipment] }

        it 'should return the right headers' do
          result = described_class.new(collection, collection_wrapper).headers

          expect(result).to eq Export::EquipmentHeaderColumnMapping::HEADERS
        end
      end

      context 'when user' do
        let(:collection) { [User.new] }

        it 'should return the right headers' do
          result = described_class.new(collection, collection_wrapper).headers

          expect(result).to eq Export::UserHeaderColumnMapping::HEADERS
        end
      end

      context 'when certification' do
        let(:collection) { [Certification.new] }

        it 'should return the right headers' do
          result = described_class.new(collection, collection_wrapper).headers

          expect(result).to eq Export::CertificationHeaderColumnMapping::HEADERS
        end
      end

      context 'when customer' do
        let(:collection) { [Customer.new] }

        it 'should return the right headers' do
          result = described_class.new(collection, collection_wrapper).headers

          expect(result).to eq Export::CustomerHeaderColumnMapping::HEADERS
        end
      end

      context 'when employee' do
        let(:collection) { [Employee.new] }

        it 'should return the right headers' do
          result = described_class.new(collection, collection_wrapper).headers

          expect(result).to eq Export::EmployeeHeaderColumnMapping::HEADERS
        end
      end
    end

    describe '#column_names' do
      context 'when equipment' do
        let(:collection) { [equipment] }

        it 'should return the right column_names' do
          result = described_class.new(collection, collection_wrapper).column_names

          expect(result).to eq Export::EquipmentHeaderColumnMapping::COLUMNS
        end
      end

      context 'when user' do
        let(:collection) { [User.new] }

        it 'should return the right column_names' do
          result = described_class.new(collection, collection_wrapper).column_names

          expect(result).to eq Export::UserHeaderColumnMapping::COLUMNS
        end
      end

      context 'when certification' do
        let(:collection) { [Certification.new] }

        it 'should return the right column_names' do
          result = described_class.new(collection, collection_wrapper).column_names

          expect(result).to eq Export::CertificationHeaderColumnMapping::COLUMNS
        end
      end

      context 'when customer' do
        let(:collection) { [Customer.new] }

        it 'should return the right column_names' do
          result = described_class.new(collection, collection_wrapper).column_names

          expect(result).to eq Export::CustomerHeaderColumnMapping::COLUMNS
        end
      end

      context 'when employee' do
        let(:collection) { [Employee.new] }

        it 'should return the right column_names' do
          result = described_class.new(collection, collection_wrapper).column_names

          expect(result).to eq Export::EmployeeHeaderColumnMapping::COLUMNS
        end
      end
    end

    describe '#each' do
      it 'should yield block to elements wrapped using collection_wrapper' do
        wrapped_collection = [EquipmentPresenter.new(Equipment.new)]
        success = false

        expect(collection_wrapper).to receive(:collection).and_return(wrapped_collection)

        sut = described_class.new(equipment_collection, collection_wrapper)

        sut.each { success = true }

        expect(success).to eq true
      end
    end
  end
end