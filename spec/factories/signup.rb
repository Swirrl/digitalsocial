FactoryGirl.define do
  factory :signup do
    first_name { Faker::Name.first_name }
    email      { Faker::Internet.email }
    password   { "password" }
    organisation_name { Faker::Company.name }
    organisation_lat  { 53.470873 }
    organisation_lng  { -2.235441 }
  end
end
