class CertificationPeriodListPresenter < ListPresenter

  def present(params = {})
    @collection = @sorter.sort(@collection, :sort_key, 'desc')
    @collection
  end
end