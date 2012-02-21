module AuthHelper

  def find_or_create_user(user_login, options = {})
    return nil if user_login.nil? || user_login == :guest
    login = user_login.to_s
    user = User.find(:first, :conditions => {:login => login})
    unless user
      password = options[:password] || login
      user = Factory.create(:user, :login => login, :password => password, :password_confirmation => password)
      puts "creating user: #{login}"
    end
    unless user.active
      user.active = true
      user.save!
    end
    user
  end

  def login_as(user_login, options={:two_factor_confirm => true})
    activate_authlogic
    user = find_or_create_user(user_login)
    UserSession.create(user)
    two_factor_confirm if options[:two_factor_confirm]
    user
  end

  def two_factor_confirm
    session[:two_factor_confirmed] = Time.now.utc.to_s(:db)
  end
end

