# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    email      { Faker::Internet.email }
    password   { "password" }
    sign_in_count 1

    factory :user_with_organisations do
      ignore do
        organisations_count 3
        owner true
      end

      after(:create) do |user, evaluator|
        FactoryGirl.create_list(:organisation_membership, evaluator.organisations_count, user: user, owner: evaluator.owner)
      end
    end
  end
end
