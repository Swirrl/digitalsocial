FactoryGirl.define do
  factory :address do
    street_address { Faker::Address.street_address }
    locality { Faker::Address.city }
    region { Faker::Address.state }
    country { Faker::Address.country }
    postal_code { Faker::Address.zip_code }
  end
end
