class SortService
  def sort(collection, sort_field, direction)
    sorted_items = collection.to_a.sort_by { |e| e.public_send(sort_field) }

    sorted_items.reverse! if direction == 'desc'

    sorted_items
  end
end