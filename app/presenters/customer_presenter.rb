class CustomerPresenter

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
end
