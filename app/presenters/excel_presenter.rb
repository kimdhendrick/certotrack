class ExcelPresenter

  attr_reader :collection

  def initialize(collection)
    @collection = collection || []

    unless collection.empty?
      klass = "#{@collection.first.class}Presenter".constantize
      @collection = @collection.map { |model| klass.new(model) }
    end
  end

  def present
    collection.to_xls(headers: equipment_headers, columns: equipment_columns, name: 'Equipment')
  end

  def equipment_columns
    EquipmentPresenterHelper::COLUMNS
  end

  def equipment_headers
    EquipmentPresenterHelper::HEADERS
  end
end