module Export
  class PdfCollectionPresenter
    def initialize(model_collection, params)
      @model_collection = model_collection
      @params = params
    end

    def collection
      ExportModelMap.new(model_collection.first.class).list_presenter.new(model_collection).sort(params)
    end

    private

    attr_reader :model_collection, :params
  end
end