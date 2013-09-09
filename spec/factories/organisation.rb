FactoryGirl.define do
  factory :organisation do
    name { Faker::Company.name }
    primary_site { FactoryGirl.create(:site).uri }
    twitter 'http://twitter.com/testing123'
    webpage 'http://testing123.com'
    organisation_type { Concepts::OrganisationType.all.first.uri }
    fte_range { Concepts::FTERange.all.first.uri }

    factory :organisation_with_users do
      ignore do
        users_count 3
      end

      after(:create) do |organisation, evaluator|
        FactoryGirl.create_list(:organisation_membership, evaluator.users_count, organisation_uri: organisation.uri.to_s)
      end
    end
  end
end
