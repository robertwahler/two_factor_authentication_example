class User < ActiveRecord::Base
  attr_accessible :login, :email, :password, :password_confirmation, :first_name, :last_name

  acts_as_authentic do |c|
  end

  before_validation :assign_two_factor_secret, :on => :create

  def assign_two_factor_secret
    self.two_factor_secret = ROTP::Base32.random_base32
  end

  # QRCode suitable for display
  #
  #   @see: app/assets/stylesheets/qr_code.css.scss
  #   @see: app/assets/stylesheets/qr_code.css.scss
  #
  def get_two_factor_secret_qr_code(size = 9, level = :h)
    secret = self.two_factor_secret
    if secret
     totp = ROTP::TOTP.new(secret)
     raw_string = totp.provisioning_uri("RailsApp #{self.email}")
     # at the default size of 9, we can accomodate ~ 100 8 bit characters
     return nil if raw_string.length >= 100
     RQRCode::QRCode.new(raw_string, :size => size, :level => level)
    end
  end

end
