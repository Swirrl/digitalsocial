module ApplicationHelper

  def project_membership_nature_options
    ProjectMembershipNature.all.resources.collect { |pmn| [pmn.label, pmn.uri] }
  end

  def current_organisation
    current_user.organisation_resources.first
  end

end
