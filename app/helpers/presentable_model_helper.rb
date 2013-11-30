module PresentableModelHelper
  def presenter_for(model = @model)
    presenter_class = "#{model.class}Presenter"
    presenter = presenter_class.constantize.new(model, self)

    if block_given?
      yield presenter
    else
      presenter
    end
  end
end
