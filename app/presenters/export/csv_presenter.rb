module Export
  class CsvPresenter

    def initialize(collection)
      @exporter = ExporterFactory.new.instance(collection, :csv)
    end

    def present
      CSV.generate do |csv|
        csv << exporter.headers

        exporter.each do |model|
          csv << exporter.column_names.map do |column_name|
            model.public_send(column_name)
          end
        end
      end
    end

    private

    attr_reader :exporter
  end
end