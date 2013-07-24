FactoryGirl.define do
  factory :signup do
    first_name { Faker::Name.first_name }
    email      { Faker::Internet.email }
    password   { "password" }
  end
end
