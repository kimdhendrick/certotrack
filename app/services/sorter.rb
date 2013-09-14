class Sorter
  def sort(collection, field, direction = 'asc')

    field = 'name' if field.blank? || field.nil?
    direction ||= 'asc'

    partitioned_collection = collection.partition { |item| item.public_send(field).nil? }

    nil_items = partitioned_collection.first

    sorted_items = partitioned_collection.last.to_a.sort_by { |item|
      item.public_send(field)
    }

    sorted_items += nil_items
    sorted_items.reverse! if direction == 'desc'

    sorted_items
  end
end