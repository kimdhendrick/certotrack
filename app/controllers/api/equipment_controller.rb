module Api
  class EquipmentController < ModelController
    include ControllerHelper

    before_filter :load_equipment_service

    def index
      _render_equipment_list(:all)
    end

    private

    def _render_equipment_list(equipment_type)
      authorize! :read, :equipment

      equipment_collection = @equipment_service.public_send("get_#{equipment_type}_equipment", current_user)

      render json: EquipmentListPresenter.new(equipment_collection).present(params).map(&:model)
    end
  end
end