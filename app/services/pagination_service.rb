require 'will_paginate/array'

class PaginationService
  def paginate(collection, page_number)
    collection.paginate(per_page: 25, page: page_number)
  end
end