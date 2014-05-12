module StatusHelper
  def status
    raise NotImplementedError
  end

  def status_code
    status.sort_order
  end

  def status_style
    status.to_s.delete('/').downcase
  end
end