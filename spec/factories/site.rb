FactoryGirl.define do
  factory :site do
    address { FactoryGirl.create(:address).uri }
    lat { Faker::Address.latitude }
    lng { Faker::Address.longitude }
  end
end
