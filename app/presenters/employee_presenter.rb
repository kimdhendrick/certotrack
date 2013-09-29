class EmployeePresenter

  attr_reader :model

  delegate :id, to: :model # new certification path, from employee show view
  delegate :first_name, to: :model # employee show view
  delegate :last_name, to: :model # employee show view
  delegate :employee_number, to: :model # employee show view
  delegate :location_id, to: :model # employee edit view

  def initialize(model)
    @model = model
  end

  def name # certification type show page (non certified employee's name)
    "#{last_name}, #{first_name}"
  end

  def location_name # employee show view
    model.location.try(:name) || "Unassigned"
  end

  def sort_key
    last_name + first_name
  end

  def errors
    model.errors
  end

  def error_count
    model.errors.count
  end
end
