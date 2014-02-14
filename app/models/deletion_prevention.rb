module DeletionPrevention
  def prevent_deletion_when_services
    model_name = self.class.model_name.human.downcase
    _prevent_deletion_of(services, "#{model_name.capitalize} has services assigned that you must remove before deleting the #{model_name}.")
  end

  private

  def _prevent_deletion_of(dependent_model, msg)
    if dependent_model.present?
      errors[:base] << msg
      false
    else
      true
    end
  end
end