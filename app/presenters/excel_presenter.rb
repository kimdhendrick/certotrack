class ExcelPresenter
  include PresenterHelper

  attr_reader :collection, :title

  def initialize(collection, title)
    @model_class = collection.first.try(&:class).try(&:to_s)
    @collection = collection_wrapped_in_presenters(collection)
    @title = title
  end

  def present
    collection.to_xls(headers: _headers, columns: _column_names, name: title)
  end
end