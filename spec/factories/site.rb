FactoryGirl.define do
  factory :site do
    address { FactoryGirl.create(:address).uri }
    lat { rand(40.027614..61.642945) }
    lng { rand(-10.898437..35.859375) }
  end
end
