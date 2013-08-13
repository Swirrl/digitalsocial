# field :requestor_id, type: String
#   field :requestor_type, type: String

#   field :requestable_id, type: String
#   field :requestable_type, type: String

#   field :data, type: Hash

#   field :is_invite, type: Boolean, default: false
#   field :responded_to, type: Boolean, default: false

FactoryGirl.define do
  factory :request do

    ignore do
      requestable { FactoryGirl.create(:project) }
      requestor { FactoryGirl.create(:organisation) }
    end

    requestor_type   { requestor.class }
    requestor_id     { requestor.respond_to?(:uri) ? requestor.uri.to_s : requestor.id }
    requestable_type { requestable.class }
    requestable_id   { requestable.respond_to?(:uri) ? requestable.uri.to_s : requestable.id }
    
    data nil
    is_invite false
    responded_to false
  end
end
