module Export
  class CsvPresenter

    def initialize(collection)
      @collection_exporter = CollectionPresenterFactory.new.instance(collection)
    end

    def present
      CSV.generate do |csv|
        csv << collection_exporter.headers

        collection_exporter.each do |model|
          csv << collection_exporter.column_names.map do |column_name|
            model.public_send(column_name)
          end
        end
      end
    end

    private

    attr_reader :collection_exporter
  end
end