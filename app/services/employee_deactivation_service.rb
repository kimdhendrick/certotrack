class EmployeeDeactivationService
  def deactivate_employee(employee)
    load_equipment_service.get_all_equipment_for_employee(employee).each do |equipment|
      equipment.employee = nil
      equipment.save
    end

    employee.deactivation_date = Date.today
    employee.active = false
    employee.save
  end

  def load_equipment_service(service = EquipmentService.new)
    @equipment_service ||= service
  end
end