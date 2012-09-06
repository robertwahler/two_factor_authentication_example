# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

user = User.create!(
  :login  => 'admin',
  :email  => 'admin@example.com',
  :first_name  => 'admin',
  :last_name => 'system',
  :password => 'admin',
  :password_confirmation => 'admin'
)

# overwrite with a known secret
user.two_factor_secret = 'v6nasf4kfe45qxbq'
user.save!

puts "demo application seed login details:"
puts "login: #{user.login}"
puts "password: #{user.password}"
puts
puts "Google Authenticator time based two_factor_secret (spaces optional): #{user.two_factor_secret.scan(/.{4}/).join(' ')}"
puts
