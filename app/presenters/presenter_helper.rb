module PresenterHelper
  def collection_wrapped_in_presenters(collection)
    presented_collection = collection || []

    return presented_collection if presented_collection.empty?

    klass = "#{presented_collection.first.class}Presenter".constantize
    presented_collection.map { |model| klass.new(model) }
  end

  private

  attr_reader :model_class

  def _headers
    return ['No results found'] if model_class.nil?

    "#{model_class}PresenterHelper".constantize::HEADERS
  end

  def _column_names
    return [] if model_class.nil?

    "#{model_class}PresenterHelper".constantize::COLUMNS
  end
end