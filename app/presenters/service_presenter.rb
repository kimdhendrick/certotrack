class ServicePresenter
  include ActionView::Helpers::NumberHelper
  include PresentableModelHelper
  include SortableByStatus

  attr_reader :model

  delegate :id,
           :comments,
           :mileage_expiration_type?,
           :date_expiration_type?,
           :expiration_type,
           :interval_date,
           :status,
           to: :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def service_type_name
    model.name
  end

  def service_due_date
    DateHelpers.date_to_string model.expiration_date
  end

  def service_due_mileage
    number_with_delimiter(model.expiration_mileage, :delimiter => ",")
  end

  def last_service_date
    DateHelpers.date_to_string model.last_service_date
  end

  def last_service_mileage
    number_with_delimiter(model.last_service_mileage, :delimiter => ",")
  end

  def interval_mileage
    number_with_delimiter(model.interval_mileage, :delimiter => ",")
  end

  def vehicle_location
    vehicle.location
  end

  def vehicle_make
    vehicle.make
  end

  def vehicle_model
    vehicle.vehicle_model
  end

  def vehicle_number
    vehicle.vehicle_number
  end

  def vehicle_year
    vehicle.year
  end

  def vehicle_vin
    vehicle.vin
  end

  def vehicle_license_plate
    vehicle.license_plate
  end

  def vehicle_mileage
    number_with_delimiter(vehicle.mileage, :delimiter => ",")
  end

  def sort_key
    model.name
  end

  def service_type_show_link
    @template.link_to model.name, model.service_type
  end

  def vehicle_show_link_by_name
    @template.link_to vehicle_name, model.vehicle
  end

  def vehicle_show_link_by_vehicle_number
    @template.link_to vehicle_number, model.vehicle
  end

  def vehicle_show_link_by_vin
    @template.link_to vehicle_vin, model.vehicle
  end

  def vehicle
    presenter_for(model.vehicle)
  end

  def vehicle_name
    vehicle.name
  end

  def edit_link
    @template.link_to 'Edit',
                      @template.edit_service_path(model),
                      data: {confirm: 'Are you sure you want to edit instead of reservice?'}
  end

  def delete_link
    @template.link_to 'Delete',
                      model,
                      method: :delete,
                      data: {confirm: 'Are you sure you want to delete this service?'}
  end

  def show_history_link
    @template.link_to 'Service History', @template.service_history_path(model)
  end

  def show_link
    @template.link_to 'Back to service', @template.service_path(model)
  end

  def reservice_link
    @template.link_to(
        'Reservice',
        @template.new_service_reservice_path(model)
    )
  end
end
