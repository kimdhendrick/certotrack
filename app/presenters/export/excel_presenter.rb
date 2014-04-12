module Export
  class ExcelPresenter
    include ListPresenterHelper
    include PresenterHelper

    attr_reader :collection, :title

    def initialize(collection, title)
      _set_model_class(collection)
      @collection = collection_wrapped_in_presenters(collection)
      @title = title
    end

    def present
      collection.to_xls(headers: _headers, columns: _column_names, name: title)
    end
  end
end