module PresenterHelper
  def collection_wrapped_in_presenters(collection)
    presented_collection = collection || []

    return presented_collection if presented_collection.empty?

    klass = "#{presented_collection.first.class}Presenter".constantize
    presented_collection.map { |model| klass.new(model) }
  end

  private

  attr_reader :model_class

  def _set_model_class(collection)
    @model_class = collection.first.try(&:class).try(&:to_s)
  end

  def _headers
    return ['No results found'] if model_class.nil?

    _header_column_mapping::HEADERS
  end

  def _column_names
    return [] if model_class.nil?

    _header_column_mapping::COLUMNS
  end

  def _header_column_mapping
    "#{model_class}HeaderColumnMapping".constantize
  end
end