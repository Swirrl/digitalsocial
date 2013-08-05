class OrganisationMembership

  include Mongoid::Document

  belongs_to :user

  field :owner, type: Boolean
  field :organisation_uri

  def organisation_resource
    Organisation.find(self.organisation_uri)
  end

  def requests
    Request.or({ sender: self }, { receiver: self })
  end

  def pending_project_invites
    Request.where(receiver: self, responded_to: false, request_type: /project.*invite/) # Clean me
  end

end