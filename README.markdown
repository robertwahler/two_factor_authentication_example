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

* Authlogic handles authentication
* QR code Google Authenticator secret entry without generating images (RQRCode)
* TFA confirmation will expire with the session
* TFA code brute force protection applies to the user, not just the session
* TFA lockout after 5 failures, requires manual reset

### Demo Limitations

Correctable in a production application

* TFA secret and TFA failure count reset is not implemented
* Users can view other user secrets, they should be scoped to the current user,
  i.e.  a 'My Account' page.
* TFA Google Authenticator secret setup requires viewing the user record, the
  demo has all IP addresses including the localhost address restricted by
  default.

### Demo Configuration Options

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

Dependencies
------------

### Runtime

* Authlogic for authentication <http://github.com/binarylogic/authlogic>
* ROTP for one time passwords <http://github.com/mdp/rotp>
* RQRCode for QR codes <http://github.com/whomwah/rqrcode>
* IPAddress for IP address range matching <http://github.com/bluemonk/ipaddress>

### Development

* Rspec for unit testing <http://github.com/rspec/rspec>


Example Application Usage
-------------------------

    git clone http://github.com/robertwahler/two_factor_authentication_example
    cd two_factor_authentication_example

    bundle install
    rake db:seed
    rails s

login: admin
password: admin
Google Authenticator time based two_factor_secret (spaces are optional): v6na sf4k fe45 qxbq

    firefox http://localhost:3000

run the RSpec test suite

    rspec


Additional References
---------------------

* <https://github.com/moomerman/two_factor_auth_rails>


Initial Example Application Generation
--------------------------------------

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

Updating
--------

    rails new .

Copyright
---------

Copyright (c) 2012 GearheadForHire, LLC. See [LICENSE](LICENSE) for details.
