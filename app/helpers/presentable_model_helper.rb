module PresentableModelHelper

  def presenter_for(model)
    presenter = "#{model.class}Presenter".constantize.new(model, self)
    if block_given?
      yield presenter
    else
      presenter
    end
  end
end