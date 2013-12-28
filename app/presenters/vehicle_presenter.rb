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

  def sortable_mileage
    model.mileage
  end

  def location
    model.location.try(&:name) || 'Unassigned'
  end

  def sort_key
    vehicle_number
  end

  def name
    license_plate + '/' + [vehicle_number, year.try(&:to_s), vehicle_model].compact.join(' ')
  end

  def edit_link
    @template.link_to 'Edit', @template.edit_vehicle_path(model)
  end

  def delete_link
    @template.link_to 'Delete', model, method: :delete, data: {confirm: 'Are you sure you want to delete this vehicle?'}
  end

  def new_service_link
    @template.link_to 'New Vehicle Service',
                      @template.new_service_path(vehicle_id: model.id, source: :vehicle)
  end
end
