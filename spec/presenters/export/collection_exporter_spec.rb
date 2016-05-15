require 'spec_helper'

module Export
  describe CollectionExporter do
    let(:equipment) { Equipment.new }
    let(:equipment_collection) { [equipment] }

    describe '#headers' do
      it 'should return the right headers' do
        result = described_class.new(equipment_collection).headers

        expect(result).to eq Export::EquipmentHeaderColumnMapping::HEADERS
      end
    end

    describe '#column_names' do
      it 'should return the right column_names' do
        result = described_class.new(equipment_collection).column_names

        expect(result).to eq Export::EquipmentHeaderColumnMapping::COLUMNS
      end
    end

    describe '#each' do
      it 'should wrap the elements in a presenter' do
        described_class.new(equipment_collection).each do |presenter|
          expect(presenter).to be_a EquipmentPresenter
          expect(presenter.model).to eq equipment
        end
      end

      it 'should yield the presented elements to the block' do
        success = false

        described_class.new(equipment_collection).each do
          success = true
        end

        expect(success).to eq true
      end
    end
  end
end