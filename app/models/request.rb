class Request

  include Mongoid::Document

  belongs_to :sender, class_name: 'OrganisationMembership'
  belongs_to :receiver, class_name: 'OrganisationMembership'

  field :requestable_id, type: String
  field :requestable_type, type: String

  field :request_type, type: String
  field :data, type: Hash

  field :responded_to, type: Boolean, default: false

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

  def accept!
    if ['project_new_organisation_invite', 'project_existing_organisation_invite'].include?(request_type) # Clean me
      accept_project_invite!
    end
  end

  def reject!
    # TODO Send rejection notification

    self.responded_to = true
    self.save
  end

  def accept_project_invite!
    transaction = Tripod::Persistence::Transaction.new

    project_membership = ProjectMembership.new
    project_membership.organisation = self.receiver.organisation_resource.uri.to_s
    project_membership.project      = self.requestable.uri.to_s
    project_membership.nature       = self.data['project_membership_nature_uri']

    if project_membership.save(transaction: transaction)
      transaction.commit

      # TODO Send acceptance notification

      self.responded_to = true
      self.save

      true
    else
      transaction.abort
      false
    end
  end

end