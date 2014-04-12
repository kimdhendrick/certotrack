module ControllerHelper
  def merge_created_by(params)
    params.merge(created_by: current_user.username)
  end

  def assign_intervals
    @intervals = Interval.all.to_a
  end

  def load_vehicle_service(service = VehicleService.new)
    @vehicle_service ||= service
  end

  def load_location_service(service = LocationService.new)
    @location_service ||= service
  end

  def load_customer_service(service = CustomerService.new)
    @customer_service ||= service
  end

  def load_user_service(service = UserService.new)
    @user_service ||= service
  end

  def load_equipment_service(service = EquipmentService.new)
    @equipment_service ||= service
  end

  def load_employee_service(service = EmployeeService.new)
    @employee_service ||= service
  end

  def load_certification_service(service = CertificationService.new)
    @certification_service ||= service
  end

  def load_certification_type_service(service = CertificationTypeService.new)
    @certification_type_service ||= service
  end

  def load_service_type_service(service = ServiceTypeService.new)
    @service_type_service ||= service
  end

  def load_vehicle_servicing_service(service = VehicleServicingService.new)
    @vehicle_servicing_service ||= service
  end

  private

  def _sort_params
    params.slice('sort', 'direction')
  end

  def _get_model(model_class, param_name = :id)
    model_pending_authorization = model_class.find(params[param_name])
    resource = model_class.name.underscore.to_sym

    if can? :manage, resource
      authorize! :manage, resource
    else
      authorize! :manage, model_pending_authorization
    end

    model_pending_authorization
  end

  def _render_search(report_title, collection)
    respond_to do |format|
      format.html { _render_search_collection_as_html(collection) }
      format.csv { _render_collection_as_csv(:search, collection) }
      format.xls { _render_collection_as_xls(report_title, :search, collection) }
      format.pdf { _render_collection_as_pdf(report_title, :search, collection) }
    end
  end

  def _render_collection_as_pdf(report_title, report_type, collection)
    send_data Export::PdfPresenter.new(collection, report_title, _sort_params).present, filename: _filename(report_type, 'pdf')
  end

  def _render_collection_as_xls(report_title, report_type, collection)
    send_data Export::ExcelPresenter.new(collection, report_title).present, filename: _filename(report_type, 'xls')
  end

  def _render_collection_as_csv(report_type, collection)
    response.headers['Content-Disposition'] = "attachment; filename=\"#{_filename(report_type, 'csv')}\""
    render text: Export::CsvPresenter.new(collection).present
  end

  def _filename(report_type, extension)
    "#{report_type}.#{extension}"
  end
end