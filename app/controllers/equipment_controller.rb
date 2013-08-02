class EquipmentController < ApplicationController
  extend EquipmentService

  before_filter :authenticate_user!
  before_action :set_equipment, only: [:show, :edit, :update, :destroy]

  check_authorization

  def index
    authorize! :read, :equipment

    @equipment = EquipmentService::get_all_equipment(current_user)
  end

  def show
    authorize! :manage, @equipment
  end

  def new
    authorize! :create, :equipment

    @equipment = Equipment.new
  end

  def edit
    authorize! :manage, @equipment
  end

  def create
    authorize! :create, :equipment

    @equipment = Equipment.new(equipment_params)
    @equipment.customer = current_user.customer

    respond_to do |format|
      if @equipment.save
        format.html { redirect_to @equipment, notice: 'Equipment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @equipment }
      else
        format.html { render action: 'new' }
        format.json { render json: @equipment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize! :manage, @equipment

    if @equipment.update(equipment_params)
      redirect_to @equipment, notice: 'Equipment was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, @equipment

    @equipment.destroy
    respond_to do |format|
      format.html { redirect_to equipment_index_url }
      format.json { head :no_content }
    end
  end

  private
  def set_equipment
    @equipment = Equipment.find(params[:id])
  end

  def equipment_params
    params.require(:equipment).permit(Equipment.accessible_parameters)
  end
end
