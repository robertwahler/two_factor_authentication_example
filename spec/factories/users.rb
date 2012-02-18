# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
 factory :user do
    login { "login"}
    email { |u| "#{u.login}@example.com" }
    first_name { "first_name" }
    last_name { "last_name" }
    password 'test'
    password_confirmation 'test'
  end
end
