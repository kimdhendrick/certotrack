class CertificationTypePresenter
  #include SortableByStatus

  attr_reader :model

  delegate :id, to: :model
  delegate :name, to: :model
  delegate :interval, to: :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def units_required_label
    return '' unless model.units_based?
    "Required Units"
  end

  def units_required
    return '' unless model.units_based?
    model.units_required
  end

  def edit_link
    @template.link_to 'Edit', @template.edit_certification_type_path(model)
  end

  def delete_link
    @template.link_to 'Delete', model, method: :delete, data: {confirm: 'Are you sure you want to delete?'}
  end
end