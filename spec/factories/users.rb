# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    email      { Faker::Internet.email }
    password   { "password" }
  end
end
