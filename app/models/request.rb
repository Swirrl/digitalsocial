class Request

  include Mongoid::Document

  belongs_to :sender, class_name: 'OrganisationMembership'
  belongs_to :receiver, class_name: 'OrganisationMembership'

  field :requestable_id, type: String
  field :requestable_type, type: String

  field :request_type, type: String
  field :data, type: Hash

  after_create :deliver_notification

  def requestable
    requestable_type.constantize.send("find", requestable_id)
  end

  def requestable=(resource)
    self.requestable_id   = resource.respond_to?(:uri) ? resource.uri : resource.id
    self.requestable_type = resource.class
  end

  def deliver_notification
    RequestMailer.send(request_type, self).deliver
  end

end