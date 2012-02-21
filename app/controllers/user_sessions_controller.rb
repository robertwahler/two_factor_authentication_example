class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  skip_before_filter :require_user, :only => [:new, :create]
  skip_before_filter :require_two_factor

  def new
    reset_session
    @user_session = UserSession.new
  end

  def create
    reset_session
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
    # TODO: allow 5 tries and then disable the user's account

    two_factor_secret = current_user.two_factor_secret
    validation_code =  params[:user_session][:validation_code]

    #puts "-------------------------------------------"
    #puts two_factor_secret
    #puts validation_code
    #puts params.inspect
    #puts "-------------------------------------------"

    if !two_factor_secret
      current_user_session.destroy
      reset_session
      flash[:notice] = "Two factor authentication is not setup on your account.  Please contact the admin."
      redirect_back login_url
    end
    else if (validation_code == ROTP::TOTP.new(two_factor_secret).now.to_s)
      session[:two_factor_confirmed] = Time.now.utc.to_s(:db)
      redirect_to :root, :notice => 'Your session is now validated'
    else
      flash[:error] = "Token invalid!"
      redirect_to :action => :confirm
    end
  end

end
