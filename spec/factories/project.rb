FactoryGirl.define do
  factory :project do
    name         { Faker::Company.catch_phrase }
    webpage      { "http://#{Faker::Internet.domain_name}" }
    activity_type_label   { Faker::Lorem.words.join(", ") }
    start_date_label { rand(5.years).ago.to_date.strftime("%B %Y") }
    end_date_label   { rand(2.years).from_now.to_date.strftime("%B %Y") }
    creator      { FactoryGirl.create(:organisation).uri.to_s }
    scoped_organisation { FactoryGirl.create(:organisation) }
    organisation_natures { [Concepts::ProjectMembershipNature.all.first.uri] }
  end
end
