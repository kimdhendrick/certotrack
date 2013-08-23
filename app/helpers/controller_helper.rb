module ControllerHelper
  def assign_inspection_intervals
    @inspection_intervals = InspectionInterval.all.to_a
  end
end