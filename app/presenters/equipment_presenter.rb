class EquipmentPresenter

  attr_reader :model

  delegate :name, to: :model
  delegate :serial_number, to: :model
  delegate :status, to: :model
  delegate :inspection_interval, to: :model
  delegate :inspection_type, to: :model
  delegate :comments, to: :model

  def initialize(model, template)
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

  def assigned_to
    assigned_to =
      model.assigned_to_location? ? model.location :
      model.assigned_to_employee? ? EmployeePresenter.new(model.employee) :
      nil

    assigned_to.try(:name) || 'Unassigned'
  end

  def last_inspection_date
    DateHelpers::date_to_string(model.last_inspection_date)
  end

  def expiration_date
    DateHelpers::date_to_string(model.expiration_date)
  end

  def edit_link
    @template.link_to 'Edit', @template.edit_equipment_path(model)
  end

  def delete_link
    @template.link_to 'Delete', model, method: :delete, data: {confirm: 'Are you sure you want to delete?'}
  end

end
