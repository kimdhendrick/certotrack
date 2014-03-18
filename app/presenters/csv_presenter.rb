class CsvPresenter

  attr_reader :collection

  def initialize(collection)
    @collection = collection || []

    unless collection.empty?
      klass = "#{@collection.first.class}Presenter".constantize
      @collection = @collection.map { |model| klass.new(model) }
    end
  end

  def present
    CSV.generate do |csv|
      csv << EquipmentPresenterHelper::HEADERS

      collection.each do |equipment|
        values = equipment_column_names.map do |column_name|
          equipment.public_send(column_name)
        end
        csv << values
      end
    end

  end

  def equipment_column_names
    EquipmentPresenterHelper::COLUMNS.map(&:to_s)
  end
end