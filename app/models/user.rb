class User < ActiveRecord::Base

  acts_as_authentic do |c|
  end

  attr_accessible :login, :email, :password, :password_confirmation, :first_name, :last_name

  def assign_two_factor_secret
    self.two_factor_secret = ROTP::Base32.random_base32
  end

end
