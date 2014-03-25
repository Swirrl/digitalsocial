FactoryGirl.define do
  factory :site do

    ignore do
      lat_range (40.027614..61.642945)
      lng_range (-10.898437..35.859375)
    end

    address { FactoryGirl.create(:address).uri }
    lat { rand(lat_range) }
    lng { rand(lng_range) }
    
  end
end
