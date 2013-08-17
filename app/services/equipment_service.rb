class EquipmentService

  def get_all_equipment(current_user, params = {})
    dynamic_sort_fields = %w(status_code inspection_interval_code inspection_type assignee)
    sort_direction = params[:direction] || 'asc'
    sort_field = params[:sort] || 'name'

    if (sort_field.in? dynamic_sort_fields)
      return _equipment_by_dynamic_sort(current_user, sort_field, sort_direction)
    end

    _equipment_by_database_sort(current_user, sort_field, sort_direction)
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


  private

  def _format_date(date)
    return nil unless date.present?
    Date.strptime(date, '%m/%d/%Y')
  end

  def _equipment_by_dynamic_sort(current_user, sort_field, direction)
    equipment = current_user.admin? ? Equipment.all : Equipment.where(customer: current_user.customer)

    sorted_equipment = equipment.to_a.sort_by { |e| e.public_send(sort_field) }

    sorted_equipment.reverse! if direction == 'desc'

    sorted_equipment
  end

  def _equipment_by_database_sort(current_user, sort_field, sort_direction)
    sort = sort_field + ' ' + sort_direction

    current_user.admin? ?
      Equipment.order(sort) :
      Equipment.where(customer: current_user.customer).order(sort)
  end
end