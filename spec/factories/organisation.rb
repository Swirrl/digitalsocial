FactoryGirl.define do
  factory :organisation do
    name { Faker::Company.name }
    primary_site { FactoryGirl.create(:site).uri }
    twitter 'http://twitter.com/testing123'
    webpage 'http://testing123.com'
    organisation_type { Concepts::OrganisationType.all.first.uri }
    fte_range { Concepts::FTERange.all.first.uri }
  end
end
