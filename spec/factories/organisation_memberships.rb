# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :organisation_membership do
    owner { [true, false].sample }
    organisation_uri { "http://example.com/organisations/foobar" }
    user
  end
end
