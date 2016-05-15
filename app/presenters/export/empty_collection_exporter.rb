module Export
  class EmptyCollectionExporter

    def headers
      ['No results found']
    end

    def column_names
      []
    end

    def each(&_)
    end
  end
end