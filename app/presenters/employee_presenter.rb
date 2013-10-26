class EmployeePresenter

  attr_reader :model

  delegate :id, to: :model
  delegate :first_name, to: :model
  delegate :last_name, to: :model
  delegate :employee_number, to: :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def name
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

  def show_batch_edit_button?(certifications)
    certifications.any?(&:units_based?)
  end

  def edit_link
    @template.link_to 'Edit', @template.edit_employee_path(model)
  end

  def delete_link
    @template.link_to 'Delete', model, method: :delete, data: {confirm: 'Are you sure you want to delete?'}
  end

  def deactivate_link
    @template.link_to 'Deactivate',
                      @template.deactivate_confirm_path(model),
                      data: {confirm: 'Deactivate Employee will unassign all equipment and remove certifications and employee. Are you sure?'}
  end

  def new_certification_link
    @template.link_to 'New Employee Certification',
                      @template.new_certification_path(employee_id: model.id, source: :employee)
  end

  def hidden_id_field
    @template.hidden_field_tag :employee_id, model.id
  end

  def units_input_field(certification, batch_certification)
    default_units = batch_certification.present? ? batch_certification.units(certification.id) : certification.units
    @template.text_field_tag "certification_ids[#{certification.id}]", default_units, size: 2
  end
end
