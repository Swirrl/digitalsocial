class Request

  include Mongoid::Document

  field :requestor_id, type: String
  field :requestor_type, type: String

  field :requestable_id, type: String
  field :requestable_type, type: String

  field :is_invite, type: Boolean, default: false
  field :responded_to, type: Boolean, default: false

  def requestable
    requestable_type.constantize.send("find", requestable_id)
  end

  def requestable=(resource)
    self.requestable_id   = resource.respond_to?(:uri) ? resource.uri : resource.id
    self.requestable_type = resource.class
  end

  def requestor
    requestor_type.constantize.send("find", requestor_id)
  end

  def requestor=(resource)
    self.requestor_id   = resource.respond_to?(:uri) ? resource.uri : resource.id
    self.requestor_type = resource.class
  end

  def reject!
    # TODO Send rejection notification

    self.responded_to = true
    self.save
  end

end