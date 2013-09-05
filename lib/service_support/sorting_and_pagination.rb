module ServiceSupport
  module SortingAndPagination
    def load_pagination_service(service = PaginationService.new)
      @pagination_service ||= service
    end

    def load_sort_service(service = SortService.new)
      @sort_service ||= service
    end

    private
    def _sort_and_paginate(collection, params)
      collection = load_sort_service.sort(collection, params[:sort], params[:direction])
      load_pagination_service.paginate(collection, params[:page])
    end
  end
end
