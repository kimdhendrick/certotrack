module Export
  class CollectionPresenter
    def initialize(model_collection, _)
      @model_collection = model_collection
    end

    def collection
      model_class = model_collection.first.class
      model_collection.map { |model| "#{model_class}Presenter".constantize.new(model) }
    end

    private

    attr_reader :model_collection
  end
end