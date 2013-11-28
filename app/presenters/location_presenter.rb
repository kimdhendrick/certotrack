class LocationPresenter

  attr_reader :model

  delegate :id, to: :model
  delegate :name, to: :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def sort_key
    name
  end

  def customer_name
    model.customer.name
  end

  def edit_link
    @template.link_to 'Edit', @template.edit_location_path(model)
  end

  def delete_link
    @template.link_to 'Delete', model, method: :delete, data: {confirm: 'Are you sure you want to delete this location?'}
  end
end
