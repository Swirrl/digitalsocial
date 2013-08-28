FactoryGirl.define do
  factory :user_request do
    user { FactoryGirl.create(:user) }
    organisation_uri { FactoryGirl.create(:organisation).uri.to_s }
    open true
    accepted nil
  end
end
