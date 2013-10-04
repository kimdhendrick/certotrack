class EmployeeListPresenter < ListPresenter

  def sort(params = {})
    _sort(params)
  end

  private

  def _sort(params = {})
    params[:sort] = 'employee_number' if params[:sort].blank? || params[:sort].nil?
    @collection = @sorter.sort(@collection, params[:sort], params[:direction])
    @collection
  end
end