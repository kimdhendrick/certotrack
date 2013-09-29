module EquipmentHelper

  def display_assigned_to(equipment)
    EquipmentPresenter.new(equipment).assigned_to
  end

  def equipment_accessible_parameters
    [
      :name,
      :serial_number,
      :inspection_interval,
      :last_inspection_date,
      :comments,
      :location_id,
      :employee_id
    ]
  end
end