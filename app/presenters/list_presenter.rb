class ListPresenter

  attr_reader :collection

  def initialize(collection, params = {})
    @collection = collection || []
    @sorter = params[:sorter] || Sorter.new
    @paginator = params[:paginator] || Paginator.new

    return if @collection.empty?

    klass = "#{@collection.first.class}Presenter".constantize

    @collection = @collection.map { |model| klass.new(model) }
  end

  def present(params = {})
    @collection = _sort(params)
    @collection = _paginate(params)
    @collection
  end

  private

  def _paginate(params)
    @paginator.paginate(@collection, params[:page])
  end

  def _sort(params = {})
    @collection = @sorter.sort(@collection, params[:sort], params[:direction])
    @collection
  end
end