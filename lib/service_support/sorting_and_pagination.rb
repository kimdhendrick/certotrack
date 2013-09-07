module ServiceSupport
  module SortingAndPagination

    private

    def _sort_and_paginate(collection, params)
      collection = @sort_service.sort(collection, params[:sort], params[:direction])
      @pagination_service.paginate(collection, params[:page])
    end
  end
end
