# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email "MyString"
    first_name "MyString"
    last_name "MyString"
    login "MyString"
  end
end
