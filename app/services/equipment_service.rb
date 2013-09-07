require 'service_support/sorting_and_pagination'

class EquipmentService
  include ServiceSupport::SortingAndPagination

  def initialize(params = {})
    @sort_service = params[:sort_service] || SortService.new
    @search_service = params[:search_service] || SearchService.new
    @pagination_service = params[:pagination_service] || PaginationService.new
  end

  def get_all_equipment(current_user, params = {})
    equipment = _get_equipment_for_user(current_user)

    equipment = @search_service.search(equipment, params)

    _sort_and_paginate(equipment, params)
  end

  def get_expired_equipment(current_user, params = {})
    equipment = _get_equipment_for_user(current_user).select { |e| e.expired? }

    _sort_and_paginate(equipment, params)
  end

  def get_expiring_equipment(current_user, params = {})
    equipment = _get_equipment_for_user(current_user).select { |e| e.expiring? }

    _sort_and_paginate(equipment, params)
  end

  def get_noninspectable_equipment(current_user, params = {})
    equipment = _get_equipment_for_user(current_user).select { |e| !e.inspectable? }

    _sort_and_paginate(equipment, params)
  end

  def count_all_equipment(current_user)
    current_user.admin? ?
      Equipment.count :
      current_user.equipments.count
  end

  def count_expired_equipment(current_user)
    get_all_equipment(current_user).select { |e| e.expired? }.count
  end

  def count_expiring_equipment(current_user)
    get_all_equipment(current_user).select { |e| e.expiring? }.count
  end

  def update_equipment(equipment, attributes)
    equipment.update(attributes)
    equipment.update(last_inspection_date: attributes['last_inspection_date'])
    equipment.update(expiration_date: _expires_on(equipment))
    equipment.save
  end

  def create_equipment(customer, attributes)
    equipment = Equipment.new(attributes)
    equipment.update(last_inspection_date: attributes['last_inspection_date'])
    equipment.update(expiration_date: _expires_on(equipment))
    equipment.customer = customer
    equipment.save
    equipment
  end

  def delete_equipment(equipment)
    equipment.destroy
  end

  def get_all_equipment_for_employee(employee)
    employee.equipments
  end

  private

  def _get_equipment_for_user(current_user)
    current_user.admin? ?
      Equipment.all :
      current_user.equipments
  end

  def _expires_on(equipment)
    ExpirationCalculator.new.calculate(equipment.last_inspection_date, Interval.find_by_text(equipment.inspection_interval))
  end
end