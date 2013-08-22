module ApplicationHelper
  def sortable(column, title = nil)
    title ||= column.titleize
    direction = _sort_direction(column)
    css_class = (column == params[:sort]) ? "current #{direction}" : nil
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

  def _sort_direction(column)
    (column == params[:sort] && params[:direction] == "asc") ? "desc" : "asc"
  end
end
