FactoryGirl.define do
  factory :project_request do

    ignore do
      requestable { FactoryGirl.create(:project) }
      requestor { FactoryGirl.create(:organisation) }
    end

    requestor_type   { requestor.class }
    requestor_id     { requestor.respond_to?(:uri) ? requestor.uri.to_s : requestor.id }
    requestable_type { requestable.class }
    requestable_id   { requestable.respond_to?(:uri) ? requestable.uri.to_s : requestable.id }
    
    is_invite false
    responded_to false
  end
end
