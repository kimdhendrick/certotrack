class TrainingEventsController < ModelController
  include AuthorizationHelper

  before_filter :_authorize_certification,
                :load_employee_service,
                :load_certification_type_service,
                :load_training_event_service

  def list_employees
    @employees = EmployeeListPresenter.new(
      @employee_service.get_all_employees(current_user)
    ).sort(params)
  end

  def list_certification_types
    if params[:employee_ids].nil?
      flash[:notice] = 'Please select at least one Employee.'
      redirect_to employee_list_training_event_path and return
    end

    @certification_types = _get_certification_type_list
    @employee_ids = params[:employee_ids].join(',')
  end

  def new
    if params[:certification_type_ids].nil?
      flash[:notice] = 'Please select at least one Certification Type.'
      @certification_types = _get_certification_type_list
      @employee_ids = params[:employee_ids]
      render 'training_events/list_certification_types' and return
    end

    employee_ids = params[:employee_ids].split(',').map(&:to_i)
    certification_type_ids = params[:certification_type_ids].map(&:to_i)

    @employees = @employee_service.find(employee_ids, current_user)
    @certification_types = @certification_type_service.find(current_user, certification_type_ids)
  end

  def create
    employee_ids = params[:employee_ids].map(&:to_i)
    certification_type_ids = params[:certification_type_ids].map(&:to_i)

    employees_pending_authorization = @employee_service.find(employee_ids, current_user)
    certification_types_pending_authorization = @certification_type_service.find(current_user, certification_type_ids)

    authorize_all(employees_pending_authorization, :manage)
    authorize_all(certification_types_pending_authorization, :manage)

    @employees = employees_pending_authorization
    @certification_types = certification_types_pending_authorization
    @trainer = params[:trainer]
    @certification_date = params[:certification_date]

    result = @training_event_service.create_training_event(
      current_user,
      @employees.map(&:id),
      @certification_types.map(&:id),
      @certification_date,
      @trainer
    )

    @employees_with_errors = result[:employees_with_errors]
    @certification_types_with_errors = result[:certification_types_with_errors]
  end

  def load_employee_service(service = EmployeeService.new)
    @employee_service ||= service
  end

  def load_certification_type_service(service = CertificationTypeService.new)
    @certification_type_service ||= service
  end

  def load_training_event_service(service = TrainingEventService.new)
    @training_event_service ||= service
  end

  private

  def _authorize_certification
    authorize! :read, :certification
  end

  def _get_certification_type_list
    CertificationTypeListPresenter.new(@certification_type_service.get_all_certification_types(current_user)).sort(params)
  end
end