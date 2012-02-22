# NOTE: There are 2 sets of configurations for Authlogic.  The session and the
# model.  These settings only affect the session. See the User model for model
# settings.
class UserSession < Authlogic::Session::Base
   # Authlogic brute force protection
  consecutive_failed_logins_limit 10
  # Authlogic brute force ban permanent
  failed_login_ban_for 0
  # The error message will be the same: "Email/Password combination is not
  # valid", whether the password or email is bad. You can change the text of the
  # message specifying a string instead of true:
  #
  # @example:
  #
  #     generalize_credentials_error_messages "Try again"
  generalize_credentials_error_messages true
  # Should the cookie be set as httponly?  If true, the cookie will not be
  # accessable from javascript
  httponly true
  # Should the cookie be set as secure?  If true, the cookie will only be sent
  # over SSL connections
  #
  # Secure the cookie when the session_store is secure (production SSL)
  secure true
end
