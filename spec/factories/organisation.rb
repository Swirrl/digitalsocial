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

    factory :organisation_with_projects do
      ignore do
        projects_count { rand(6) }
      end

      after(:create) do |organisation, evaluator|
        FactoryGirl.create_list(:project, evaluator.projects_count, scoped_organisation: organisation)
      end
    end

    factory :organisation_near_lat_lng do
      ignore do
        near [53.479324, -2.248485]
      end

      primary_site { FactoryGirl.create(:site, lat_range: (near.first-0.1..near.first+0.1), lng_range: (near.last-0.1..near.last+0.1)).uri }
    end
  end
end
