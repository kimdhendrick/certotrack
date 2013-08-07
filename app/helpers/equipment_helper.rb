module EquipmentHelper

  def display_assigned_to(equipment)
    equipment.assigned_to.try(:to_s) || 'Unassigned'
  end

  def equipment_accessible_parameters
    [
      :name,
      :serial_number,
      :inspection_interval,
      :last_inspection_date,
      :inspection_type,
      :notes,
      :location_id,
      :employee_id
    ]
  end
end