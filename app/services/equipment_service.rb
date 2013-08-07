class EquipmentService

  def get_all_equipment(current_user)
    if (current_user.admin?)
      Equipment.all
    else
      Equipment.where(customer: current_user.customer)
    end
  end

  def get_expired_equipment(current_user)
    get_all_equipment(current_user).select { |e| e.expired? }
  end

  def get_expiring_equipment(current_user)
    get_all_equipment(current_user).select { |e| e.expiring? }
  end

  def get_noninspectable_equipment(current_user)
    get_all_equipment(current_user).select { |e| !e.inspectable? }
  end

  def count_all_equipment(current_user)
    if (current_user.admin?)
      Equipment.count
    else
      Equipment.where(customer: current_user.customer).count
    end
  end

  def count_expired_equipment(current_user)
    get_all_equipment(current_user).select { |e| e.expired? }.count
  end

  def count_expiring_equipment(current_user)
    get_all_equipment(current_user).select { |e| e.expiring? }.count
  end

  def update_equipment(equipment, attributes)
    equipment.update(attributes)
    equipment.update(expiration_date: equipment.expires_on)
    equipment.save
  end

  def create_equipment(customer, attributes)
    equipment = Equipment.new(attributes)
    equipment.update(expiration_date: equipment.expires_on)
    equipment.customer = customer
    equipment
  end
end