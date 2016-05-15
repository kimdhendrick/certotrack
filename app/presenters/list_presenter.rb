class ListPresenter
  attr_reader :collection

  def initialize(collection, params = {})
    @collection = _collection_wrapped_in_presenters(collection)
    @sorter = params[:sorter] || Sorter.new
    @paginator = params[:paginator] || Paginator.new
  end

  def present(params = {})
    @collection = _sort(params)
    @collection = _paginate(params)
    @collection
  end

  def sort(params = {})
    _sort(params)
  end

  private

  def _collection_wrapped_in_presenters(collection)
    presented_collection = collection || []

    return presented_collection if presented_collection.empty?

    klass = "#{presented_collection.first.class}Presenter".constantize
    presented_collection.map { |model| klass.new(model) }
  end

  def _paginate(params)
    @paginator.paginate(@collection, params[:page])
  end

  def _sort(params = {})
    @collection = @sorter.sort(@collection, params[:sort], params[:direction])
    @collection
  end
end