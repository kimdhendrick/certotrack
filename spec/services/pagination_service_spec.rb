require 'spec_helper'

describe PaginationService do
  describe 'paginate' do
    it 'calls paginate with correct parameters' do
      collection = []

      certotrack_rows_per_page = 25

      collection.should_receive(:paginate).with({per_page: certotrack_rows_per_page, page: 2}).once

      PaginationService.new.paginate(collection, 2)
    end
  end
end
