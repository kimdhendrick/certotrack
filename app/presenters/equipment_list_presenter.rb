class EquipmentListPresenter < ListPresenter

  private

  def _sort(params = {})
    @collection = @sorter.sort(@collection, params[:sort], params[:direction])
    @collection
  end
end