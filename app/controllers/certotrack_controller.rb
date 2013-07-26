class CertotrackController < ApplicationController
  before_filter :authenticate_user!

  def home
  end

  def signed_in
    render json: { signed_in: user_signed_in? }
  end
end