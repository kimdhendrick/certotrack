module LocationsHelper

  def location_presenter_for(location = @location)
    yield LocationPresenter.new(location, self)
  end

  def location_accessible_parameters
    [
      :name,
      :customer_id
    ]
  end
end