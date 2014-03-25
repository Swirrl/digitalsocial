FactoryGirl.define do
  factory :project_invite do
    invitor_organisation_uri { FactoryGirl.create(:organisation).uri.to_s }
    invited_organisation_uri { FactoryGirl.create(:organisation).uri.to_s }
    project_uri { FactoryGirl.create(:project).uri.to_s }
    open true
    accepted nil

    factory :project_invite_with_invited_user do
      invited_email { Faker::Internet.email }
      invited_user_name { Faker::Name.name }
    end
  end
end
