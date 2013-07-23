# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tripod_organisation do
    name { Faker::Company.name }
    lat  { "#{rand(-89..89)}.#{"%08d" % rand(10**8)}" }
    lng  { "#{rand(-179..179)}.#{"%08d" % rand(10**8)}" }
  end
end
