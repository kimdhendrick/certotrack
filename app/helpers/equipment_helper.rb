module EquipmentHelper

  def equipment_presenter_for(equipment = @equipment)
    presenter = EquipmentPresenter.new(equipment, self)
    if block_given?
      yield presenter
    else
      presenter
    end
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