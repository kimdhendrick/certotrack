module DeletionPrevention
  def prevent_deletion_when_services
    if services.present?
      model_name = self.class.model_name.human.downcase
      errors[:base] << "#{model_name.capitalize} has services assigned that you must remove before deleting the #{model_name}."
      false
    else
      true
    end
  end
end