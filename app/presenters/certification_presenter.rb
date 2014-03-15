class CertificationPresenter
  include SortableByStatus
  include EmployeesHelper
  include LinkHelper

  attr_reader :model

  delegate :id,
           :units_required,
           :units_based?,
           :interval,
           :trainer,
           :status,
           :comments,
           :name,
           to: :model

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

  def last_certification_date_sort_key
    model.last_certification_date
  end

  def expiration_date_sort_key
    model.expiration_date
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
    presenter_for(model.employee)
  end

  def employee_name
    employee.name
  end

  def certification_type
    model.certification_type.name
  end

  def interval_code
    Interval.lookup(interval)
  end

  def units_required_sort_key
    model.units_required
  end

  def units_achieved_label
    return '' unless model.units_based?
    'Units Achieved'
  end

  def units_achieved_of_required
    return '' unless model.units_based?
    "#{model.units_achieved} of #{model.units_required}"
  end

  def units
    model.units_achieved.to_s if model.units_based?
  end

  def edit_link
    @template.link_to 'Edit',
                      @template.edit_certification_path(model),
                      data: {confirm: 'Are you sure you want to edit instead of recertify?'}
  end

  def delete_link
    confirm_delete_link 'Are you sure you want to delete this certification?'
  end

  def recertify_link
    @template.link_to 'Recertify', @template.new_certification_recertification_path(model)
  end

  def show_history_link
    @template.link_to 'Certification History', @template.certification_history_path(model)
  end

  def show_link
    @template.link_to 'Back to certification', @template.certification_path(model)
  end
end