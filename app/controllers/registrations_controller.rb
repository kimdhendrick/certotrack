class RegistrationsController < ApplicationController
  skip_before_action :authenticate_user!

  before_filter :load_registration_service

  def new
    @registration = Registration.new
    @subscriptions = Subscription.all
  end

  def create
    success, @registration = @registration_service.register(_registration_params)

    if !success
      render action: :new
    end
  end

  def load_registration_service(service = RegistrationService.new)
    @registration_service ||= service
  end

  private

  def _registration_params
    params.require(:registration).permit(
        [
            :first_name,
            :last_name,
            :customer_name,
            :password,
            :subscription,
        ]
    ).merge(
        {
            payment_token: params[:stripeToken],
            payment_email: params[:stripeEmail]
        }
    )
  end
end
