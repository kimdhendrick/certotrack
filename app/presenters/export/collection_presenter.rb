module Export
  class CollectionPresenter
    def initialize(model_collection, _)
      @model_collection = model_collection
    end

    def collection
      model_collection.map do |model|
        ExportModelMap.new(model_collection.first.class).presenter.new(model)
      end
    end

    private

    attr_reader :model_collection
  end
end