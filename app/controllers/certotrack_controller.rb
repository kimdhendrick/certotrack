class CertotrackController < ApplicationController
  def home
  end

  def signed_in
    render json: { signed_in: user_signed_in? }
  end
end