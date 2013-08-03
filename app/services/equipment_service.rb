module EquipmentService

  def self.get_all_equipment(current_user)
    if (current_user.admin?)
      Equipment.all
    else
      Equipment.where(customer: current_user.customer)
    end
  end

  def self.get_expired_equipment(current_user)
    get_all_equipment(current_user).select { |e| e.expired? }
  end

  def self.count_all_equipment(current_user)
    if (current_user.admin?)
      Equipment.count
    else
      Equipment.where(customer: current_user.customer).count
    end
  end

  def self.count_expired_equipment(current_user)
    get_all_equipment(current_user).select { |e| e.expired? }.count
  end

  def self.count_expiring_equipment(current_user)
    get_all_equipment(current_user).select { |e| e.expiring? }.count
  end

  def self.update_equipment(equipment, attributes)
    equipment.update(attributes)
    equipment.update(inspection_type: equipment.calculate_inspection_type)
    equipment.update(expiration_date: equipment.expires_on)
    equipment.save
  end

  def self.create_equipment(customer, attributes)
    equipment = Equipment.new(attributes)
    equipment.update(inspection_type: equipment.calculate_inspection_type)
    equipment.update(expiration_date: equipment.expires_on)
    equipment.customer = customer
    equipment
  end
end