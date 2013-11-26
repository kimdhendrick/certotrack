class CustomerListPresenter < ListPresenter
  def sort(params = {})
    _sort(params)
  end
end