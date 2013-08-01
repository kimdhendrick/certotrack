module EquipmentService

  def self.get_all_equipment(current_user)
    if (current_user.admin?)
      Equipment.all
    else
      Equipment.where(customer: current_user.customer)
    end
  end
end