class EquipmentPresenter
  include SortableByStatus
  include LinkHelper

  attr_reader :model

  delegate :name,
           :serial_number,
           :status,
           :inspection_interval,
           :inspection_type,
           :comments,
           to: :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def assigned_to_label
    if model.assigned_to_location?
      @template.content_tag(:b, 'Location')
    elsif model.assigned_to_employee?
      @template.content_tag(:b, 'Employee')
    else
      @template.content_tag(:b, 'Assignee')
    end
  end

  def assignee
    assigned_to =
      model.assigned_to_location? ? model.location :
        model.assigned_to_employee? ? EmployeePresenter.new(model.employee) :
          nil

    assigned_to.try(:name) || 'Unassigned'
  end

  def sort_key
    name
  end

  def inspection_interval_code
    Interval.lookup(inspection_interval)
  end

  def last_inspection_date
    DateHelpers::date_to_string(model.last_inspection_date)
  end

  def last_inspection_date_sort_key
    model.last_inspection_date
  end

  def expiration_date
    DateHelpers::date_to_string(model.expiration_date)
  end

  def expiration
    model.expiration_date
  end

  def created_at
    DateHelpers::date_to_string(model.created_at)
  end

  def edit_link
    @template.link_to 'Edit', @template.edit_equipment_path(model)
  end

  def delete_link
    confirm_delete_link 'Are you sure you want to delete this equipment?'
  end
end
