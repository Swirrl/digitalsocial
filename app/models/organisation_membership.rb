class OrganisationMembership

  include Mongoid::Document

  belongs_to :user

  field :owner, type: Boolean
  field :organisation_uri

  def organisation_resource
    Organisation.find(self.organisation_uri)
  end

end