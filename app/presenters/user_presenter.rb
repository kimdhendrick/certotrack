class UserPresenter

  attr_reader :model

  delegate :id,
           :username,
           :first_name,
           :last_name,
           to: :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def sort_key
    username
  end
end
