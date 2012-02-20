class UserSessionsController < ApplicationController
  skip_before_filter :require_user, :only => [:new, :create]
  skip_before_filter :require_two_factor, :only => [:new, :create, :confirm, :validate]

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back '/'
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back login_url
  end

  def confirm
  end

  def validate
    puts params.inspect
    #session[:two_factor_confirmed] = UUIDTools::UUID.timestamp_create.to_s
    session[:two_factor_confirmed] = Time.now.utc
    # add code to store valid in session
    redirect_to :root, :notice => 'Your session is now validated'
  end

end
