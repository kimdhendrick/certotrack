class VehiclePresenter
  include ActionView::Helpers::NumberHelper
  include StatusHelper
  include LinkHelper

  attr_reader :model

  delegate :id,
           :vehicle_number,
           :vin,
           :license_plate,
           :make,
           :year,
           :vehicle_model,
           :tire_size,
           to: :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def mileage
    number_with_delimiter(model.mileage, delimiter: ',')
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

  def status
    model.status.text
  end

  def status_code
    model.status.sort_order
  end

  def edit_link
    @template.link_to 'Edit', @template.edit_vehicle_path(model), class: "button tiny radius"
  end

  def delete_link
    confirm_delete_link 'Are you sure you want to delete this vehicle?'
  end

  def new_service_link
    @template.link_to 'New Vehicle Service',
                      @template.new_service_path(vehicle_id: model.id, source: :vehicle),
                      {class: "button tiny radius"}
  end
end
