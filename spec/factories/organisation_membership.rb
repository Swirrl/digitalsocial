# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :organisation_membership do
    owner { true }
    organisation_uri { FactoryGirl.create(:organisation).uri.to_s }
    user { FactoryGirl.create(:user) }
  end
end
