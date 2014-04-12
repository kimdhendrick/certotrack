module Export
  class CsvPresenter
    include ListPresenterHelper
    include PresenterHelper

    attr_reader :collection

    def initialize(collection)
      _set_model_class(collection)
      @collection = collection_wrapped_in_presenters(collection)
    end

    def present
      CSV.generate do |csv|
        csv << _headers

        collection.each do |equipment|
          values = _column_names.map do |column_name|
            equipment.public_send(column_name)
          end
          csv << values
        end
      end
    end
  end
end