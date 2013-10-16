class RecertificationsController < ApplicationController

  before_filter :authenticate_user!

  before_action :_set_certification, only: [:new, :create]

  check_authorization

  def new
  end

  def create
    puts '*********************'
    puts "params: #{params}"
    puts '*********************'
    redirect_to @certification, notice: "Brown, Joe recertifed for Certification: Inspections."
  end

  private

  def _set_certification
    certification_pending_authorization = Certification.find(params[:certification_id])
    authorize! :manage, certification_pending_authorization
    @certification = certification_pending_authorization
  end
end
