class EquipmentSearchService
  def search(active_record_relation, params)

    query = nil
    query_params = {}

    [:name, :serial_number].each do |search_field|
      if params[search_field].present?
        query = _build_query(query, "#{search_field.to_s} ILIKE :#{search_field}")
        query_params[search_field] = "%#{params[search_field]}%"
      end
    end

    [:employee_id, :location_id].each do |search_field|
      if params[search_field].present?
        query = _build_query(query, "#{search_field.to_s} = :#{search_field}")
        query_params[search_field] = params[search_field]
      end
    end

    active_record_relation.where(query, query_params)
  end

  private


  def _build_query(existing_query, query_addition)
    existing_query.present? ?
      existing_query + ' OR ' + query_addition :
      query_addition
  end
end
