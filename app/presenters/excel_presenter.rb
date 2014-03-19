class ExcelPresenter
  include PresenterHelper

  attr_reader :collection, :title

  def initialize(collection, title)
    @collection = collection_wrapped_in_presenters(collection)
    @title = title
  end

  def present
    collection.to_xls(headers: equipment_headers, columns: equipment_columns, name: title)
  end

  def equipment_columns
    EquipmentPresenterHelper::COLUMNS
  end

  def equipment_headers
    EquipmentPresenterHelper::HEADERS
  end
end