module ListPresenterHelper
  def collection_wrapped_in_presenters(collection)
    presented_collection = collection || []

    return presented_collection if presented_collection.empty?

    klass = "#{presented_collection.first.class}Presenter".constantize
    presented_collection.map { |model| klass.new(model) }
  end
end