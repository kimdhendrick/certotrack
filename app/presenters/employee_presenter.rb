class EmployeePresenter
  include LinkHelper

  attr_reader :model

  delegate :id,
           :first_name,
           :last_name,
           :employee_number,
           :created_by,
           to: :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def name
    "#{last_name}, #{first_name}"
  end

  def location_name
    model.location.try(:name) || 'Unassigned'
  end

  def sort_key
    last_name + first_name
  end

  def show_batch_edit_button?(certifications)
    certifications.any?(&:units_based?)
  end

  def deactivation_date
    DateHelpers::date_to_string(model.deactivation_date)
  end

  def created_at
    DateHelpers::date_to_string(model.created_at)
  end

  def edit_link
    @template.link_to 'Edit', @template.edit_employee_path(model), class: "button tiny radius"
  end

  def delete_link
    confirm_delete_link 'Are you sure you want to delete this employee?'
  end

  def deactivate_link
    @template.link_to 'Deactivate',
                      @template.deactivate_confirm_path(model),
                      {
                        data: {confirm: 'Deactivate Employee will unassign all equipment and remove certifications and employee. Are you sure?'},
                        class: "button tiny radius"
                      }
  end

  def reactivate_link
    @template.link_to 'Reactivate',
                      @template.reactivate_path(model),
                      {
                        data: {confirm: 'Reactivate Employee will restore the employee. All previous certifications will be reactivated. Previously assigned equipment will not be modified. Are you sure?'},
                        class: "button tiny radius"
                      }
  end

  def new_certification_link
    @template.link_to 'New Employee Certification',
                      @template.new_certification_path(employee_id: model.id, source: :employee),
                      {class: "button tiny radius"}
  end

  def hidden_id_field
    @template.hidden_field_tag :employee_id, model.id
  end

  def units_input_field(certification, batch_certification)
    default_units = batch_certification.present? ? batch_certification.units(certification.id) : certification.units
    @template.text_field_tag "certification_ids[#{certification.id}]", default_units, size: 2
  end

  def export_to_csv_link
    @template.link_to 'Export to CSV',
                      @template.employee_path(format: 'csv', id: model.id)
  end

  def export_to_xls_link
    @template.link_to 'Export to Excel',
                      @template.employee_path(format: 'xls', id: model.id)
  end

  def export_to_pdf_link(params)
    @template.link_to 'Export to PDF',
                      @template.employee_path(model, format: 'pdf', sort: params[:sort], direction: params[:direction])
  end
end
