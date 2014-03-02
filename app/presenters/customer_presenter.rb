class CustomerPresenter

  attr_reader :model

  delegate :id,
           :name,
           :account_number,
           :contact_person_name,
           :contact_phone_number,
           :contact_email,
           :address1,
           :address2,
           :city,
           :state,
           :zip,
           to: :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def sort_key
    name
  end

  def equipment_access
    _yes_no(model.equipment_access?)
  end

  def certification_access
    _yes_no(model.certification_access?)
  end

  def vehicle_access
    _yes_no(model.vehicle_access?)
  end

  def locations
    LocationListPresenter.new(model.locations).sort
  end

  private

  def _yes_no(truthy)
    truthy ? 'Yes' : 'No'
  end
end
