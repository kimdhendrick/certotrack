class EquipmentController < ApplicationController
  before_action :set_equipment, only: [:show, :edit, :update, :destroy]

  check_authorization

  def index
    # This is not perfect.  Cancan can't (ha!) authorize multiple
    # objects, so for now only enforcing 'read' access and controller
    # must be responsible for limiting to customer's equipment
    authorize! :read, :equipment

    @equipment = Equipment.where(customer: current_user.customer).all

    # Not needed if remove BB
    respond_to do |format|
      format.html
      format.json { render json: @equipment }
    end

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

    respond_to do |format|
      if @equipment.update(equipment_params)
        format.html { redirect_to @equipment, notice: 'Equipment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @equipment.errors, status: :unprocessable_entity }
      end
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
