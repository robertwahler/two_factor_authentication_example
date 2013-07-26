class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  skip_before_filter :require_user, :only => [:new, :create]
  skip_before_filter :require_two_factor

  def new
    @user_session = UserSession.new
  end

  def create
    clear_session
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      if two_factor_required?
        flash[:notice] = "Login successful, security token required"
        redirect_to confirm_url
      else
        flash[:notice] = "Login successful!"
        redirect_back '/'
      end
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    reset_session
    flash[:notice] = "Logout successful!"
    redirect_back login_url
  end

  def confirm
  end

  def validate
    two_factor_secret = current_user.two_factor_secret
    validation_code =  params[:user_session][:validation_code]

    if !two_factor_secret
      current_user_session.destroy
      reset_session
      flash[:error] = "Two factor authentication is not setup on your account.  Please contact the admin."
      redirect_back login_url
    elsif current_user.two_factor_failure_count_exceeded?
      current_user_session.destroy
      reset_session
      flash[:error] = "Two factor confirmation failure count exceeded.  Please contact the admin."
      redirect_to :root
    elsif validate_code(validation_code.to_i, two_factor_secret)
      session[:two_factor_confirmed_at] = current_user.confirm_two_factor!
      flash[:notice] = 'Your session has been confirmed'
      redirect_back :root
    else
      current_user.increment_two_factor_failure_count!
      flash[:error] = "Token invalid!"
      redirect_to :action => :confirm
    end
  end

  private

  # clear the entire session except for the return_to redirect
  def clear_session
    return_to = session[:return_to]
    reset_session
    session[:return_to] = return_to if return_to
  end

  # True if code validates within the sliding window
  #
  # @return [Boolean]
  def validate_code(validation_code, two_factor_secret)
    valid_codes = []
    valid_codes << ROTP::TOTP.new(two_factor_secret).now
    (1..sliding_window_width).each do |index|
      valid_codes << ROTP::TOTP.new(two_factor_secret).at(Time.now.ago(30 * index))
      valid_codes << ROTP::TOTP.new(two_factor_secret).at(Time.now.in(30 * index))
    end

    valid_codes.include?(validation_code.to_i)
  end

  # Use a sliding time window to validate tokens.  System clock inaccuracy can
  # be tolerated at the expense a small decrease in security.   A value of 0
  # will disable the sliding window
  #
  # A value of 2 will check tokens in two windows before and after the current
  # 30 second window. ie. +/- 60 seconds surrounding the current window.
  #
  # @return [Integer] width of the window in 30 second increments
  def sliding_window_width
    1
  end

end
