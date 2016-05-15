module Export
  class CollectionPresenterFactory
    def instance(collection)
      return EmptyCollectionExporter.new if collection.empty?

      CollectionExporter.new(collection)
    end
  end
end