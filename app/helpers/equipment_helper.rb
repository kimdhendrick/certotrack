module EquipmentHelper

  def display_assigned_to(equipment)
    equipment.assigned_to.try(:name) || 'Unassigned'
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