class VehiclePresenter
  include ActionView::Helpers::NumberHelper
  include SortableByStatus

  attr_reader :model

  delegate :id, to: :model
  delegate :vehicle_number, to: :model
  delegate :vin, to: :model
  delegate :license_plate, to: :model
  delegate :make, to: :model
  delegate :year, to: :model
  delegate :vehicle_model, to: :model
  delegate :status, to: :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def mileage
    number_with_delimiter(model.mileage, :delimiter => ",")
  end

  def location
    model.location.try(&:name) || 'Unassigned'
  end

  def sort_key
    vehicle_number
  end
end
