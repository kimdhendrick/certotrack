require 'spec_helper'
require 'service_support/sorting_and_pagination'

class ConcreteSortingAndPagination
  include ServiceSupport::SortingAndPagination

  def initialize(params = {})
    @sort_service = params[:sort_service] || SortService.new
    @pagination_service = params[:pagination_service] || PaginationService.new
  end

  def sort_and_paginate(collection, params)
    _sort_and_paginate(collection, params)
  end
end

module ServiceSupport
  describe SortingAndPagination do
    subject { ConcreteSortingAndPagination.new(sort_service: sort_service, pagination_service: pagination_service) }
    let(:sort_service) { double('sort_service') }
    let(:pagination_service) { double('pagination_service') }

    it 'should sort and paginate' do
      sort_service.should_receive(:sort)
      pagination_service.should_receive(:paginate)
      subject.sort_and_paginate([], {})
    end
  end
end