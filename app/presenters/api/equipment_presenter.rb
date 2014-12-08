module Api
  class EquipmentPresenter

    def initialize(equipment)
      @equipment = equipment
    end

    def present
      {
        'id' => equipment.model.id,
        'name' => equipment.name,
        'serial_number' => equipment.serial_number,
        'status' => equipment.status_text,
        'expiration_date' => equipment.expiration_date || '',
        'last_inspection_date' => equipment.last_inspection_date,
        'inspection_interval' => equipment.inspection_interval,
        'expiration_date' => equipment.expiration_date,
        'assigned_to' => equipment.assignee,
        'comments' => equipment.comments || ''
      }
    end

    private

    attr_reader :equipment
  end
end