require 'spec_helper'

module Export
  describe CollectionPresenterFactory do
    context 'when collection is empty' do
      it 'should return EmptyCollectionExporter' do
        result = described_class.new.instance([])

        expect(result).to be_a EmptyCollectionExporter
      end
    end

    context 'when collection is not empty' do
      it 'should return CollectionExporter' do
        result = described_class.new.instance([Equipment.new])

        expect(result).to be_a CollectionExporter
      end
    end
  end
end