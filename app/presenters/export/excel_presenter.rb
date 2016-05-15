module Export
  class ExcelPresenter
    def initialize(collection, title)
      @exporter = ExporterFactory.new.instance(collection, :xls)
      @title = title
    end

    def present
      exporter.collection.to_xls(headers: exporter.headers, columns: exporter.column_names, name: title)
    end

    private

    attr_reader :exporter, :title
  end
end