class CsvPresenter
  include PresenterHelper

  attr_reader :collection

  def initialize(collection)
    @collection = collection_wrapped_in_presenters(collection)
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