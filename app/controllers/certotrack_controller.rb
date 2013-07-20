class CertotrackController < ApplicationController

  def welcome
  end

  def home
    logger.info "*" * 30
    logger.info "#{DateTime.now} in certotrack home...!"
    logger.info "You are logged in? #{signed_in?}"
    logger.info "*" * 30
    if !signed_in?
      render location: '#welcome'
    end
  end
end