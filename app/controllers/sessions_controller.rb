class SessionsController < ApplicationController

  def create
    user = User.find_by_email(params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_to '#home'
    else
      flash[:error] = 'Invalid email/password combination'
      redirect_to '#welcome'
    end
  end

  def destroy
    sign_out
    redirect_to '#welcome'
  end

  def signed_in
    render json: {signed_in: signed_in?}
  end
end