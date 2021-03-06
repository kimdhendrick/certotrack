class CertificationPresenter
  include StatusHelper
  include EmployeesHelper
  include LinkHelper

  attr_reader :model

  delegate :id,
           :units_required,
           :units_based?,
           :interval,
           :status,
           :name,
           :created_by,
           to: :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def trainer
    return if _never_certified?

    model.trainer
  end

  def comments
    return if _never_certified?

    model.comments
  end

  def sort_key
    model.name
  end

  def last_certification_date
    DateHelpers.date_to_string model.last_certification_date
  end

  def expiration_date
    return if _never_certified?

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

  def employee_number
    model.employee.employee_number
  end

  def location
    model.employee.location
  end

  def location_name
    employee.location_name
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
    return if _date_based?

    'Units Achieved'
  end

  def units_achieved_of_required
    return if _date_based? || _never_certified?

    "#{model.units_achieved} of #{model.units_required}"
  end

  def units
    return if _date_based? || _never_certified?

    model.units_achieved.to_s
  end

  def status_text
    status.text
  end

  def created_at
    DateHelpers::date_to_string(model.created_at)
  end

  def edit_link
    @template.link_to 'Edit',
                      @template.edit_certification_path(model),
                      {
                        data: {confirm: 'Are you sure you want to edit instead of recertify?'},
                        class: 'button tiny radius'
                      }
  end

  def delete_link
    confirm_delete_link 'Are you sure you want to delete this certification?'
  end

  def recertify_link
    @template.link_to 'Recertify', @template.new_certification_recertification_path(model), {class: 'button tiny radius'}
  end

  def show_history_link
    @template.link_to 'Certification History', @template.certification_history_path(model)
  end

  def show_link
    @template.link_to 'Back to certification', @template.certification_path(model)
  end

  private

  def _date_based?
    !model.units_based?
  end

  def _never_certified?
    !model.active_certification_period.present?
  end
end