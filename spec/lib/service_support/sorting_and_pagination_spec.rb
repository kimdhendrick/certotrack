require 'spec_helper'
require 'service_support/sorting_and_pagination'

class ConcreteSortingAndPagination
  include ServiceSupport::SortingAndPagination

  def initialize(params = {})
    @sorter = params[:sorter] || Sorter.new
    @paginator = params[:paginator] || Paginator.new
  end

  def sort_and_paginate(collection, params)
    _sort_and_paginate(collection, params)
  end
end

module ServiceSupport
  describe SortingAndPagination do
    subject { ConcreteSortingAndPagination.new(sorter: sorter, paginator: paginator) }
    let(:sorter) { double('sorter') }
    let(:paginator) { double('paginator') }

    it 'should sort and paginate' do
      sorter.should_receive(:sort)
      paginator.should_receive(:paginate)
      subject.sort_and_paginate([], {})
    end
  end
end