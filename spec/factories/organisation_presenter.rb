FactoryGirl.define do
  factory :organisation_presenter do
    user { FactoryGirl.create(:user) }
    name      { Faker::Company.name }
    lat  { 53.470873 }
    lng  { -2.235441 }
    street_address { Faker::Address.street_name }
    locality { Faker::Address.secondary_address }
    region { Faker::Address.state }
    country { Faker::Address.country }
    postal_code { Faker::Address.zip_code }
  end
end
