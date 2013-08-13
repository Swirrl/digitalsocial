FactoryGirl.define do
  factory :project do
    label                 { Faker::Company.catch_phrase }
    webpage               { Faker::Internet.domain_name }
    activity_types_list   { Faker::Lorem.words.join(", ") }
    start_date            { rand(5.years).ago.to_date }
    end_date              { rand(2.years).from_now.to_date }
    creator_role          { FactoryGirl.create(:project_membership_nature).uri.to_s }
  end
end
