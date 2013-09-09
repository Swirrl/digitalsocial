class RequestMailer < ActionMailer::Base
  default from: "contact@digitalsocial.eu"

  def project_new_organisation_invite(invite, user)
    @invite = invite
    @user = user
    mail to: @user.email, subject: "You've been invited to join a project on DigitalSocialInnovation"
  end

  def organisation_invite(user, organisation)
    @user = user
    @organisation = organisation
    mail to: @user.email, subject: "You've been invited to join an organisation on DigitalSocialInnovation"
  end

  def request_digest(user, organisation)
    @user = user
    @organisation = organisation
    mail to: @user.email, subject: "There are items awaiting your response on DigitalSocialInnovation for #{organisation.name}"
  end

  def project_request_acceptance(project_request, user)
    @project_request = project_request
    @project = @project_request.project_resource
    @organisation = @project_request.requestor_organisation_resource
    @user = user

    mail to: @user.email, subject: "Your activity request has been accepted"
  end

  def user_request_acceptance(user_request, user)
    @user_request = user_request
    @organisation = @user_request.organisation_resource
    @user = user

    mail to: @user.email, subject: "Your requst to join an organisation has been accepted"
  end

end
