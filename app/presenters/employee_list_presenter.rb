class EmployeeListPresenter

  attr_reader :collection

  def initialize(collection, params = {})
    @collection = collection
    @sorter = params[:sorter] || Sorter.new
    @paginator = params[:paginator] || Paginator.new

    return if collection.empty?

    @collection = collection.map { |model| EmployeePresenter.new(model) }
  end

  def present(params = {})
    params[:sort] = 'employee_number' if params[:sort].blank? || params[:sort].nil?

    @collection = @sorter.sort(@collection, params[:sort], params[:direction])
    @collection = @paginator.paginate(@collection, params[:page])

    @collection
  end
end