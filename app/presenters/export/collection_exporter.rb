module Export
  class CollectionExporter

    def initialize(collection, collection_wrapper)
      model_class = collection.first.class
      @collection = collection_wrapper.collection
      @mapping = "Export::#{model_class}HeaderColumnMapping".constantize
    end

    def each(&block)
      collection.each { |model| block.call(model) }
    end

    def headers
      mapping::HEADERS
    end

    def column_names
      mapping::COLUMNS
    end

    private

    attr_reader :mapping, :collection
  end
end