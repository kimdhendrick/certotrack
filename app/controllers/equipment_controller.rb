class EquipmentController < ApplicationController
  extend EquipmentService

  before_filter :authenticate_user!
  before_action :set_equipment, only: [:show, :edit, :update, :destroy]

  check_authorization

  def index
    authorize! :read, :equipment

    @report_title = 'All Equipment List'
    @equipment = EquipmentService::get_all_equipment(current_user)
    @equipment_count = @equipment.count
  end

  def expired
    authorize! :read, :equipment

    @report_title = 'Expired Equipment List'
    @equipment = EquipmentService::get_expired_equipment(current_user)
    @equipment_count = @equipment.count
    render 'equipment/index'
  end

  def show
  end

  def new
    authorize! :create, :equipment

    @equipment = Equipment.new
  end

  def edit
  end

  def create
    authorize! :create, :equipment

    @equipment = EquipmentService::create_equipment(current_user.customer, equipment_params)

    if @equipment.save
      redirect_to @equipment, notice: 'Equipment was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    success = EquipmentService::update_equipment(@equipment, equipment_params)

    if success
      redirect_to @equipment, notice: 'Equipment was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @equipment.destroy
    redirect_to equipment_index_url
  end

  private
  def set_equipment
    equipment_pending_authorization = Equipment.find(params[:id])
    authorize! :manage, equipment_pending_authorization
    @equipment = equipment_pending_authorization
  end

  def equipment_params
    params.require(:equipment).permit(Equipment.accessible_parameters)
  end
end
