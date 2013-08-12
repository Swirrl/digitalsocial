FactoryGirl.define do
  factory :project_invite do
    project_uri { FactoryGirl.create(:project).uri.to_s }
    nature_uri  { FactoryGirl.create(:project_membership_nature).uri.to_s }

    factory :project_invite_for_new_organisation do
      organisation_name { Faker::Company.name }
      user_first_name   { Faker::Name.first_name }
      user_email        { Faker::Internet.email }
      new_organisation  true
    end

    factory :project_invite_for_existing_organisation do
      organisation_uri  { FactoryGirl.create(:organisation).uri.to_s }
    end

  end
end
