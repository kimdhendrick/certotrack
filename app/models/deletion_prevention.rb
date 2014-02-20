module DeletionPrevention
  def prevent_deletion_of(dependent_model, msg)
    if dependent_model.present?
      errors[:base] << msg
      false
    else
      true
    end
  end
end