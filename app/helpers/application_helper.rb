module ApplicationHelper

  def project_membership_nature_options
    ProjectMembershipNature.all.resources.collect { |pmn| [pmn.label, pmn.uri] }
  end

  def current_organisation
    current_user.organisation_resources.first
  end

  def current_organisation_membership
    current_user.organisation_memberships.where(organisation_uri: current_organisation.uri.to_s).first
  end

end
