class PresentableEmployee

  attr_reader :employee_model

  delegate :id, to: :employee_model
  delegate :first_name, to: :employee_model
  delegate :last_name, to: :employee_model
  delegate :employee_number, to: :employee_model
  delegate :customer, to: :employee_model
  delegate :location, to: :employee_model
  delegate :location_id, to: :employee_model
  delegate :certifications, to: :employee_model
  delegate :equipments, to: :employee_model

  def initialize(employee_model)
    @employee_model = employee_model
  end

  def name
    "#{last_name}, #{first_name}"
  end

  def sort_key
    last_name + first_name
  end

  def location_name
    location.try(:to_s) || "Unassigned"
  end
end
