module Export
  class PdfCollectionPresenter
    def initialize(model_collection, params)
      @model_collection = model_collection
      @params = params
    end

    def collection
      model_class = model_collection.first.class
      "#{model_class}ListPresenter".constantize.new(model_collection).sort(params)
    end

    private

    attr_reader :model_collection, :params
  end
end