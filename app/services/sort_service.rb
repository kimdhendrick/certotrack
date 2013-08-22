class SortService
  def sort(collection, field, direction, default_field = 'name')
    field = _sort_field(collection, field, default_field)

    sorted_items = collection.to_a.sort_by { |e| e.public_send(field) }

    sorted_items.reverse! if direction == 'desc'

    sorted_items
  end

  def _sort_field(collection, sort_field, default_field)
    return if collection.empty?

    collection.first.respond_to?(sort_field) ? sort_field : default_field
  end
end