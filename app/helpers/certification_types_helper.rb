module CertificationTypesHelper

  def certification_type_presenter_for(certification_type = @certification_type)
    presenter = CertificationTypePresenter.new(certification_type, self)
    if block_given?
      yield presenter
    else
      presenter
    end
  end

  def certification_type_accessible_parameters
    [
      :name,
      :interval,
      :units_required
    ]
  end
end