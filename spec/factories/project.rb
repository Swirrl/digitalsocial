FactoryGirl.define do
  factory :project do
    name         { Faker::Company.catch_phrase.titleize }
    description  { Faker::Lorem.paragraph }
    webpage      { "http://#{Faker::Internet.domain_name}" }
    activity_type_label   { Faker::Lorem.words.join(", ") }
    start_date_label { rand(5.years).ago.to_date.strftime("%B %Y") }
    end_date_label   { rand(2.years).from_now.to_date.strftime("%B %Y") }
    #creator      { FactoryGirl.create(:organisation).uri.to_s }
    scoped_organisation { FactoryGirl.create(:organisation) }
    organisation_natures { [Concepts::ProjectMembershipNature.all.first.uri] }

    activity_type { Concepts::ActivityType.first.uri }
    areas_of_society { [Concepts::AreaOfSociety.first.uri] }
    technology_focus { [Concepts::TechnologyFocus.first.uri] }
    technology_method { [Concepts::TechnologyMethod.first.uri] }

    factory :project_with_network_activity do
      activity_type { Concepts::ActivityType.from_label("network").uri }
    end

    factory :project_with_organisations do
      ignore do
        organisations_count { rand(6) }
      end

      after(:create) do |project, evaluator|
        FactoryGirl.create_list(:project_membership, evaluator.organisations_count, project: project.uri.to_s)
      end
    end
  end
end