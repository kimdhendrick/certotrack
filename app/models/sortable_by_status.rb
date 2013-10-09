module SortableByStatus
  def status
    raise NotImplementedError
  end

  def status_code
    status.sort_order
  end
end