class User < ActiveRecord::Base
  attr_accessible :login, :email, :password, :password_confirmation, :first_name, :last_name

  acts_as_authentic do |c|
  end

  before_validation :assign_two_factor_secret, :on => :create

  def assign_two_factor_secret
    self.two_factor_secret = ROTP::Base32.random_base32
  end

  def confirm_two_factor!
    reset_two_factor_failure_count!
    value = UUIDTools::UUID.timestamp_create.to_s
    update_attribute :two_factor_confirmed_at, value
    value
  end

  def two_factor_confirmed_at_valid?
    return false unless self.two_factor_confirmed_at
    begin
      uuid = UUIDTools::UUID.parse(self.two_factor_confirmed_at)
      uuid.valid? && lambda { (Time.now.utc < (uuid.timestamp.utc + two_factor_confirmed_at_valid_for)) }.call
    rescue
      return false
    end
  end

  # length of time in seconds the TFA confirmation is valid
  def two_factor_confirmed_at_valid_for
    12.hours
  end

  def reset_two_factor_failure_count!
    update_attribute :two_factor_failure_count, 0
  end

  def increment_two_factor_failure_count!
    count = self.two_factor_failure_count
    count += 1
    update_attribute :two_factor_failure_count, count
  end

  # lock out TFA if true
  def two_factor_failure_count_exceeded?
    self.two_factor_failure_count >= 5
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
