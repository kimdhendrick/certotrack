class CertotrackController < ApplicationController
  before_filter :authenticate_user!
  extend EquipmentService

  def home
    if can? :read, :equipment
      @total_equipment_count = EquipmentService::count_all_equipment(current_user)
      @expired_equipment_count = EquipmentService::count_expired_equipment(current_user)
      @expiring_equipment_count = EquipmentService::count_expiring_equipment(current_user)
    end
  end
end