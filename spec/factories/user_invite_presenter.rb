FactoryGirl.define do
  factory :user_invite_presenter do
    user_first_name { Faker::Name.first_name }
    user_email      { Faker::Internet.email }
    organisation    { FactoryGirl.create(:organisation) }
  end
end
