module ControllerHelper
  def assign_intervals
    @intervals = Interval.all.to_a
  end
end