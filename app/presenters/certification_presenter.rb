class CertificationPresenter
  include SortableByStatus
  include EmployeesHelper

  attr_reader :model

  delegate :units_based?, to: :model
  delegate :interval, to: :model
  delegate :trainer, to: :model
  delegate :status, to: :model
  delegate :comments, to: :model
  delegate :name, to: :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def sort_key
    model.name
  end

  def last_certification_date
    DateHelpers.date_to_string model.last_certification_date
  end

  def expiration_date
    DateHelpers.date_to_string model.expiration_date
  end

  def certification_type_show_link
    @template.link_to model.name, model.certification_type
  end

  def employee_show_link
    @template.link_to employee.name, model.employee
  end

  def employee_model
    model.employee
  end

  def location
    model.employee.location
  end

  def employee
    employee_presenter_for(model.employee)
  end

  def employee_name
    employee.name
  end

  def units_achieved_label
    return '' unless model.units_based?
    "Units Achieved"
  end

  def units_achieved
    return '' unless model.units_based?
    "#{model.units_achieved} of #{model.units_required}"
  end

  def edit_link
    @template.link_to 'Edit',
                      @template.edit_certification_path(model),
                      data: {confirm: 'Are you sure you want to edit instead of recertify?'}
  end

  def delete_link
    @template.link_to 'Delete',
                      model,
                      method: :delete,
                      data: {confirm: 'Are you sure you want to delete this certification?'}
  end
end