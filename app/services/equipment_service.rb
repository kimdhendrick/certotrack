module EquipmentService

  def self.get_all_equipment(current_user)
    if (current_user.admin?)
      Equipment.all
    else
      Equipment.where(customer: current_user.customer)
    end
  end

  def self.count_all_equipment(current_user)
    if (current_user.admin?)
      Equipment.count
    else
      Equipment.where(customer: current_user.customer).count
    end
  end

  def self.count_expired_equipment(current_user)
    get_all_equipment(current_user).select{|equipment| equipment.status == Status::EXPIRED}.count
  end

  def self.count_expiring_equipment(current_user)
    get_all_equipment(current_user).select{|equipment| equipment.status == Status::WARNING}.count
  end
end