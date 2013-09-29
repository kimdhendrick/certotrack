class EquipmentPresenter

  attr_reader :model

  def initialize(model)
    @model = model
  end

  def assigned_to
    assigned_to =
      @model.assigned_to_location? ? @model.location :
        @model.assigned_to_employee? ? EmployeePresenter.new(@model.employee) :
          nil

    assigned_to.try(:name) || 'Unassigned'
  end

end