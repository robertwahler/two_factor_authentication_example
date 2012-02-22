class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all
  helper_method :current_user_session, :current_user
  before_filter :require_user # must be logged in, redirect to login if not
  before_filter :require_two_factor # verify two factor token

  private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to login_url
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to '/'
      return false
    end
  end

  def require_two_factor
    return unless current_user && two_factor_required?
    unless two_factor_confirmed?
      redirect_to confirm_url
      return false
    end
  end

  def two_factor_required?
    request_ip = IPAddress.parse(request.ip)
    two_factor_excluded_ip_addresses.each do |excluded_ip|
      return false if excluded_ip.include?(request_ip)
    end
    return true
  end

  # two factor exclude IP addresses, these addresses will bypass TFA
  #
  # @example allow localhost 127.0.0.0 -> 127.0.0.255 to bypass authentication
  #
  #   [IPAddress.parse("127.0.0.1/24")]
  #
  # @example allow no addresses to bypass
  #
  #   []
  #
  # @return [Array] of exclude IP address objects
  def two_factor_excluded_ip_addresses
    []
  end

  # NOTE:
  # 'two_factor_confirmed?' doesn't persist with "remember_me", it dies
  # with the session.
  #
  # NOTE:
  # If the Authlogic session expires/goes stale, the entire session (except for
  # :return_to) will be reset on the next redirect to a new user session.
  #
  # @return [Boolean] true if two factor confirmed
  def two_factor_confirmed?
    #current_user.two_factor_confirmed_at && session[:two_factor_confirmed_at] == current_user.two_factor_confirmed_at
    current_user.two_factor_confirmed_at_valid? && session[:two_factor_confirmed_at] == current_user.two_factor_confirmed_at
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to '/'
      return false
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

end
