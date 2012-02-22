Two Factor Authentication Example
=================================

A bare bones example Rails 3.2 application and test suite demonstrating the use of the
[Authlogic](https://github.com/binarylogic/authlogic) gem and custom
[two-factor authentication (TFA)](http://en.wikipedia.org/wiki/Two-factor_authentication>)
with [Google authenticator](http://code.google.com/p/google-authenticator/) support.


Typical Use Case
-----------------

Intranet application with username/password authentication for LAN users.  Remote users
are required to use TFA.

### Demo Features

* Authlogic handles authentication, there are no changes to Authlogic, TFA is
  completely separate and invoked after Authlogic authorization.
* Google Authenticator QR code secret entry without generating images (RQRCode)
  or sending secrets to the charting services.
* TFA confirmation will expire with the session but can expire before the
  session if required.
* TFA confirmation code brute force protection applies to the user, not just
  the session.  Lockout after 5 failures, requires manual reset.

### Demo Limitations

Correctable in a production application

* Production implementations must use SSL otherwise this implementation, and
  Authlogic itself, is vulnerable to [session
  hijacking](http://guides.rubyonrails.org/security.html#session-hijacking).
  See below for configuration options.
* TFA secret and TFA failure count reset is not implemented
* Users can view other user secrets, they should be scoped to the current user,
  i.e.  a 'My Account' page.
* TFA Google Authenticator secret setup requires viewing the user record, the
  demo has all IP addresses including the localhost address restricted by
  default.  This can be changed.  See configuration options below.

Example Application Usage
-------------------------

    git clone http://github.com/robertwahler/two_factor_authentication_example
    cd two_factor_authentication_example

    bundle install

    rake db:migrate
    rake db:seed

    rails server

login creditials for the admin user

    login: admin
    password: admin
    Google Authenticator time based two_factor_secret (spaces are optional): v6na sf4k fe45 qxbq

run the app

    firefox http://localhost:3000

run the RSpec test suite

    rake db:test:prepare

    rspec


### Demo Configuration Options

#### TFA configuration

Change TFA brute force failure count in app/models/user.rb

    def two_factor_failure_count_exceeded?
      self.two_factor_failure_count >= 5
    end

Change length of time the TFA confirmation is valid in app/models/user.rb

    def two_factor_confirmed_at_valid_for
      12.hours
    end

#### Excluding IP Ranges from TFA

Change ApplicationController to allow localhost subnet to access without TFA

      def two_factor_excluded_ip_addresses
        [IPAddress.parse("127.0.0.1/24")]
      end

Change ApplicationController to allow LAN subnet to access without TFA

      def two_factor_excluded_ip_addresses
        [IPAddress.parse("10.0.0.1/24")]
      end

Change ApplicationController to allow both localhost and LAN subnet to access without TFA

      def two_factor_excluded_ip_addresses
        [IPAddress.parse("127.0.0.1/24"), IPAddress.parse("10.0.0.1/24")]
      end

### Forcing SSL in Production

config/environments/production.rb

    # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
    config.force_ssl = true

app/models/user_session.rb

    # Should the cookie be set as httponly?  If true, the cookie will not be
    # accessable from javascript
    httponly true

    # Should the cookie be set as secure?  If true, the cookie will only be sent
    # over SSL connections
    #
    # Secure the cookie when the session_store is secure (production SSL)
    secure true

config/initializers/session_store.rb

add these options to the session_store

    :httponly => true,
    :secure => Rails.env.production?

Dependencies
------------

### Runtime

* Authlogic for authentication <http://github.com/binarylogic/authlogic>
* ROTP for one time passwords <http://github.com/mdp/rotp>
* RQRCode for QR codes <http://github.com/whomwah/rqrcode>
* IPAddress for IP address range matching <http://github.com/bluemonk/ipaddress>
* UUIDTools for confirmation token timestamps <http://github.com/sporkmonger/uuidtools>

### Development

* Rspec for unit testing <http://github.com/rspec/rspec>



Additional References
---------------------

* <https://github.com/moomerman/two_factor_auth_rails>


Example Application Generation
------------------------------

### Initial generation

rails version

    rails -v

        Rails 3.2.1

generate basic rails application

    rails new two_factor_authentication_example --skip-bundle -T

Gemfile

    gem "authlogic", "~> 3.1.0"
    gem "rotp", "~> 1.3.2"
    gem "rqrcode", "~> 0.4.2"
    gem "ipaddress", "~> 0.8.0"
    gem 'uuidtools', "~> 2.1.2"

    group :test, :development do
      gem "ruby-debug"
      gem "rspec-rails", "~> 2.8"
      gem "factory_girl_rails", "~> 1.6"
      gem "capybara", "~> 1.1"
      gem "database_cleaner", "~> 0.7.1"
      gem "timecop", "= 0.3.5"
    end

Gemfile.lock

    bundle update

basic user scaffold and manual authlogic configuration

    rails generate scaffold user email:string first_name:string last_name:string login:string --fixture-replacement

add admin user seed

     rake db:seed


### Future Rails updates

    rails new .


Copyright
---------

Copyright (c) 2012 GearheadForHire, LLC. See [LICENSE](LICENSE) for details.
