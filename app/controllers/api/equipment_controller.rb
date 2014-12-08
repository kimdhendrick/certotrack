module Api
  class EquipmentController < ModelController
    include ControllerHelper

    before_filter :load_equipment_service

    def names
      authorize! :read, :equipment

      render json: @equipment_service.get_equipment_names(current_user, '')
    end

    def find_all_by_name
      authorize! :read, :equipment

      equipment_collection = @equipment_service.search_equipment(current_user, {name: params[:name]})
      results = EquipmentListPresenter.new(equipment_collection).sort.map do |equipment|
        Api::EquipmentPresenter.new(equipment).present
      end

      render json: results
    end
  end
end