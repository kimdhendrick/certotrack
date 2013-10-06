module SortableByStatus
  def status
    # :nocov:
    raise NotImplementedError
    # :nocov:
  end

  def status_code
    status.sort_order
  end
end