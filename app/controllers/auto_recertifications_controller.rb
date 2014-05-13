class AutoRecertificationsController < ModelController
  include ControllerHelper

  before_filter :authenticate_user!,
                :load_certification_service

  before_action :_set_certification_type, only: [:new, :create]

  def new
    @certifications = @certification_type.valid_certifications
  end

  def create
    unless params[:certification_ids] && params[:certification_ids].any?
      flash[:error] = 'Please select at least one certification.'
      redirect_to new_certification_type_auto_recertification_path
      return
    end

    certifications = Certification.find(params[:certification_ids])

    certifications.each { |certification|
      if can? :manage, :certification
        authorize! :manage, :certification
      else
        authorize! :manage, certification
      end
    }

    result = @certification_service.auto_recertify(certifications)

    if result == :success
      flash[:success] = 'Auto Recertify successful.'
      redirect_to certification_type_url(@certification_type)
    else
      flash[:error] = 'A system error has occurred. Please contact support@certotrack.com.'
      redirect_to new_certification_type_auto_recertification_path(@certification_type)
    end
  end

  private

  def _set_certification_type
    @certification_type = _get_model(CertificationType, :certification_type_id)
  end
end