FactoryGirl.define do
  factory :project_invite_presenter do

    project_uri { FactoryGirl.create(:project).uri.to_s }
    invitor_organisation_uri { FactoryGirl.create(:organisation).uri.to_s }
    
    factory :project_invite_presenter_for_new_organisation do
      invited_organisation_name { Faker::Company.name }
      invited_user_name   { Faker::Name.first_name }
      invited_email        { Faker::Internet.email }
      personalised_message { Faker::Lorem.paragraph }
    end

    factory :project_invite_presenter_for_existing_organisation do
      invited_organisation_uri  { FactoryGirl.create(:organisation).uri.to_s }


      factory :project_invite_presenter_for_existing_organisation_with_email_and_user_name do
        invited_organisation_uri  { FactoryGirl.create(:organisation).uri.to_s }
        invited_email { Faker::Internet.email }
        invited_user_name { Faker::Name.name }
      end
    end
  end
end
