class EquipmentService

  def get_all_equipment(current_user, params = {})
    equipment = _get_equipment_for_user(current_user)

    _sort_equipment(equipment, params)
  end

  def get_expired_equipment(current_user, params = {})
    equipment = _get_equipment_for_user(current_user).select { |e| e.expired? }

    _sort_equipment(equipment, params)
  end

  def get_expiring_equipment(current_user, params = {})
    equipment = _get_equipment_for_user(current_user).select { |e| e.expiring? }

    _sort_equipment(equipment, params)
  end

  def get_noninspectable_equipment(current_user, params = {})
    equipment = _get_equipment_for_user(current_user).select { |e| !e.inspectable? }

    _sort_equipment(equipment, params)
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
    equipment.update(last_inspection_date: _format_date(attributes['last_inspection_date']))
    equipment.update(expiration_date: equipment.expires_on)
    equipment.save
  end

  def create_equipment(customer, attributes)
    equipment = Equipment.new(attributes)
    equipment.update(last_inspection_date: _format_date(attributes['last_inspection_date']))
    equipment.update(expiration_date: equipment.expires_on)
    equipment.customer = customer
    equipment
  end

  def load_sort_service(service = SortService.new)
    @sort_service ||= service
  end


  private

  def _format_date(date)
    return nil unless date.present?
    Date.strptime(date, '%m/%d/%Y')
  end

  def _get_equipment_for_user(current_user)
    current_user.admin? ? Equipment.all : Equipment.where(customer: current_user.customer)
  end

  def _sort_equipment(equipment, params)
    load_sort_service.sort(equipment, params[:sort] || 'name', params[:direction] || 'asc')
  end
end