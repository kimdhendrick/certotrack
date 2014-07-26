class SearchService
  def search(active_record_relation, params)

    query = nil
    query_params = {}

    query = _build_name_and_serial_number_query(params, query, query_params)
    query = _build_employee_and_location_query(params, query, query_params)
    query = _build_certification_type_or_employee_name_query(params, query, query_params)
    query = _build_certification_type_query(params, query)
    query = _build_vehicle_query(params, query, query_params)

    active_record_relation.where(query, query_params)
  end

  private

  def _build_employee_and_location_query(params, query, query_params)
    [:employee_id, :location_id].each do |search_field|
      if params[search_field].present?
        query = _build_and_query(query, "#{search_field.to_s} = :#{search_field}")
        query_params[search_field] = params[search_field]
      end
    end
    query
  end

  def _build_name_and_serial_number_query(params, query, query_params)
    [:name, :serial_number].each do |search_field|
      if params[search_field].present?
        query = _build_and_query(query, "#{search_field.to_s} ILIKE :#{search_field}")
        query_params[search_field] = "%#{params[search_field]}%"
      end
    end
    query
  end

  def _build_certification_type_or_employee_name_query(params, query, query_params)
    return query unless params[:certification_type_or_employee_name].present?

    search_field = :certification_type_or_employee_name

    query_params[search_field] = "%#{params[:certification_type_or_employee_name]}%"

    _build_and_query(
      query,
      "(name ILIKE :#{search_field} OR first_name ILIKE :#{search_field} OR last_name ILIKE :#{search_field})"
    )
  end

  def _build_certification_type_query(params, query)
    return query unless params[:certification_type].present?

    params[:certification_type] == 'units_based' ?
      _build_and_query(query, 'units_required > 0') :
      _build_and_query(query, 'units_required = 0')
  end

  def _build_vehicle_query(params, query, query_params)
    [:make, :vehicle_model].each do |search_field|
      if params[search_field].present?
        query = _build_and_query(query, "#{search_field.to_s} ILIKE :#{search_field}")
        query_params[search_field] = "%#{params[search_field]}%"
      end
    end
    query
  end

  def _build_and_query(existing_query, query_addition)
    existing_query.present? ?
      "(#{existing_query} AND #{query_addition})" :
      "(#{query_addition})"
  end
end
