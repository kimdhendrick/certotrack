class Sorter
  def sort(collection, field, direction = 'asc', default_field = 'name')
    field = _sort_field(collection, field, default_field)

    partitioned_collection = collection.partition { |item| item.public_send(field).nil? }

    nil_items = partitioned_collection.first

    sorted_items = partitioned_collection.last.to_a.sort_by { |item|
      item.public_send(field)
    }

    sorted_items += nil_items
    sorted_items.reverse! if direction == 'desc'

    sorted_items
  end

  def _sort_field(collection, sort_field, default_field)
    return if collection.empty?

    collection.first.respond_to?(sort_field) ? sort_field : default_field
  end
end