module EquipmentHelper
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