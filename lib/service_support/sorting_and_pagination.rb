module ServiceSupport
  module SortingAndPagination

    private

    def _sort_and_paginate(collection, params)
      collection = @sorter.sort(collection, params[:sort], params[:direction])
      @paginator.paginate(collection, params[:page])
    end
  end
end
