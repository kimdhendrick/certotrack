module Export
  class CollectionExporter

    attr_reader :collection, :headers, :column_names

    def initialize(collection, collection_wrapper)
      @collection = collection_wrapper.collection

      map = ExportModelMap.new(collection.first.class)
      @headers = map.headers
      @column_names = map.columns
    end

    def each(&block)
      collection.each { |model| block.call(model) }
    end
  end
end