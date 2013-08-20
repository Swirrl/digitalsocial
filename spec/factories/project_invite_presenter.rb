FactoryGirl.define do
  factory :project_invite_presenter do
    project_uri { FactoryGirl.create(:project).uri.to_s }
    nature_uri  { ProjectMembershipNature.all.first.uri }

    factory :project_invite_presenter_for_new_organisation do
      organisation_name { Faker::Company.name }
      user_first_name   { Faker::Name.first_name }
      user_email        { Faker::Internet.email }
      new_organisation  true
    end

    factory :project_invite_presenter_for_existing_organisation do
      organisation_uri  { FactoryGirl.create(:organisation).uri.to_s }
    end

  end
end
