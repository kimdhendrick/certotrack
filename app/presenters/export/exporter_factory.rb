module Export
  class ExporterFactory

    def instance(collection, format, options = {})
      return EmptyCollectionExporter.new if collection.empty?

      CollectionExporter.new(collection, export_mapping(collection, options)[format].call)
    end

    def export_mapping(collection, options)
      {
          :csv => -> { CsvCollectionPresenter.new(collection, options) },
          :pdf => -> { PdfCollectionPresenter.new(collection, options) },
      }
    end
  end
end