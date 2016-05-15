require 'spec_helper'

module Export
  describe ExporterFactory do
    describe '#instance' do
      context 'when collection is empty' do
        it 'should return EmptyCollectionExporter' do
          result = described_class.new.instance([], nil)

          expect(result).to be_a EmptyCollectionExporter
        end
      end

      context 'when collection is not empty' do
        let(:collection) { [Equipment.new] }

        context 'when csv' do
          it 'should return a CollectionExporter' do
            expect(described_class.new.instance(collection, :csv)).to be_a CollectionExporter
          end

          it 'should use CsvCollectionPresenter' do
            csv_collection_presenter = double(:csv_collection_presenter, collection: [])
            allow(CsvCollectionPresenter).to receive(:new)
                                               .with(collection, {})
                                               .and_return(csv_collection_presenter)

            collection_exporter = double(:collection_exporter)
            allow(CollectionExporter).to receive(:new)
                                           .with(collection, csv_collection_presenter)
                                           .and_return(eq collection_exporter)

            expect(described_class.new.instance(collection, :csv)).to eq collection_exporter
          end
        end

        context 'when pdf' do
          it 'should return a CollectionExporter' do
            expect(described_class.new.instance(collection, :pdf)).to be_a CollectionExporter
          end

          it 'should use PdfCollectionPresenter' do
            pdf_collection_presenter = double(:pdf_collection_presenter, collection: [])
            allow(PdfCollectionPresenter).to receive(:new)
                                               .with(collection, {})
                                               .and_return(pdf_collection_presenter)

            collection_exporter = double(:collection_exporter)
            allow(CollectionExporter).to receive(:new)
                                           .with(collection, pdf_collection_presenter)
                                           .and_return(eq collection_exporter)

            expect(described_class.new.instance(collection, :pdf)).to eq collection_exporter
          end
        end
      end
    end
  end
end