FactoryGirl.define do
  factory :user_request do

    ignore do
      requestable { FactoryGirl.create(:organisation) }
    end

    requestable_type { requestable.class }
    requestable_id   { requestable.respond_to?(:uri) ? requestable.uri.to_s : requestable.id }
    
    user_first_name { Faker::Name.first_name }
    user_email      { Faker::Internet.email }

    is_invite false
    responded_to false
  end
end
