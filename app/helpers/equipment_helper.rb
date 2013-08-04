module EquipmentHelper
  def self.accessible_parameters
    [
      :name,
      :serial_number,
      :inspection_interval,
      :last_inspection_date,
      :inspection_type,
      :notes,
      :location_id
    ]
  end
end