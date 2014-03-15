class CertificationTypePresenter
  include LinkHelper

  attr_reader :model

  delegate :id, to: :model
  delegate :name, to: :model
  delegate :interval, to: :model
  delegate :units_based?, to: :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def interval_code
    Interval.lookup(interval)
  end

  def sort_key
    name
  end

  def units_required_label
    return '' unless model.units_based?
    "Required Units"
  end

  def units_required
    return '' unless model.units_based?
    model.units_required
  end

  def units_required_sort_key
    model.units_required
  end

  def show_batch_edit_button?(certifications)
    model.units_based? && certifications.present?
  end

  def edit_link
    @template.link_to 'Edit', @template.edit_certification_type_path(model)
  end

  def delete_link
    confirm_delete_link 'Are you sure you want to delete this certification type?'
  end

  def auto_recertify_link
    return '' unless model.units_based? && model.has_valid_certification?
    "| #{@template.link_to('Auto Recertify', @template.new_certification_type_auto_recertification_path(model))}"
  end

  def hidden_id_field
    @template.hidden_field_tag :certification_type_id, model.id
  end

  def units_input_field(certification, batch_certification)
    default_units = batch_certification.present? ? batch_certification.units(certification.id) : certification.units
    @template.text_field_tag "certification_ids[#{certification.id}]", default_units, size: 2
  end
end