module LocationsHelper
  include PresentableModelHelper

  def location_accessible_parameters
    [
      :name,
      :customer_id
    ]
  end
end