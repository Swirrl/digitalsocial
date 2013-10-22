FactoryGirl.define do
  factory :project_invite_presenter do

    project_uri { FactoryGirl.create(:project).uri.to_s }
    invitor_organisation_uri { FactoryGirl.create(:organisation).uri.to_s }

    factory :project_invite_presenter_for_new_organisation do
      invited_organisation_name { Faker::Company.name }
      user_first_name   { Faker::Name.first_name }
      user_email        { Faker::Internet.email }
    end

    factory :project_invite_presenter_for_existing_organisation do
      invited_organisation_uri  { FactoryGirl.create(:organisation).uri.to_s }
    end

    factory :project_invite_presenter_by_organisation_guid do
      invited_organisation_id  { FactoryGirl.create(:organisation).guid }
    end

  end
end
