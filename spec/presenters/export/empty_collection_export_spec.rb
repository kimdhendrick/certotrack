require 'spec_helper'

module Export
  describe EmptyCollectionExporter do
    describe '#headers' do
      it 'should return empty headers' do
        result = described_class.new.headers

        expect(result).to eq ['No results found']
      end
    end

    describe '#column_names' do
      it 'should return empty column_names' do
        result = described_class.new.column_names

        expect(result).to eq []
      end
    end

    describe '#each' do
      it 'should do nothing' do
        described_class.new.each do
          fail 'should not call me!'
        end
      end
    end

    describe '#collection' do
      it 'should return empty collection' do
        expect(described_class.new.collection).to eq([])
      end
    end
  end
end