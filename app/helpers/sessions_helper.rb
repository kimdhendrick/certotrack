module SessionsHelper

  def require_user
    logger.info("requiring user, current_user = #{current_user}");
    return if current_user

    respond_to do |format|
      format.html { redirect_to login_path }
      format.all  { render :text => 'unauthorized', :status => :unauthorized }
    end
  end

  def current_user
    logger.info("getting current_user = #{@current_user}")
    return @current_user if @current_user

    logger.info("looking in session for current_user...")
    if session[:user_id]
      logger.info("Found session[:user_id] = #{session[:user_id]}")
      @current_user = User.find(session[:user_id])
      logger.info("returning @current_user = #{@current_user}")
    end
    @current_user
  end

  def inspect_user
    logger.info("session[:user_id] = #{session[:user_id]} and self.current_user = #{self.current_user}")
  end

  def sign_in(user)
    logger.info("signing in...")
    self.current_user = user
    session[:user_id] = user.id
    inspect_user
  end

  def sign_out
    logger.info("signing out...")
    self.current_user = nil
    session[:user_id] = nil
    inspect_user
  end

  def current_user=(user)
    logger.info("setting current_user=")
    @current_user = user
  end

  def signed_in?
    !current_user.nil?
  end
end