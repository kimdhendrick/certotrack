class Sorter
  def sort(collection, field, direction = 'asc')

    field = 'sort_key' if field.blank? || field.nil?
    direction = 'asc' if direction.blank? || direction.nil?

    partitioned_collection = collection.partition { |item| item.public_send(field).nil? }

    nil_items = partitioned_collection.first

    sorted_items = partitioned_collection.last.to_a.sort_by { |item|
      sort_key = item.public_send(field)
      sort_key.respond_to?(:downcase) ? sort_key.downcase : sort_key
    }

    sorted_items += nil_items
    sorted_items.reverse! if direction == 'desc'

    sorted_items
  end
end