class EquipmentListPresenter < ListPresenter

  def sort(params = {})
    @collection = @sorter.sort(@collection, params[:sort], params[:direction])
    @collection
  end
end