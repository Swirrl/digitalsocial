class OrganisationMembership

  include Mongoid::Document

  belongs_to :user

  field :owner, type: Boolean
  field :organisation_uri

end