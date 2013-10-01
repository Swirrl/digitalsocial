class RequestMailer < ActionMailer::Base
  default from: "contact@digitalsocial.eu"

  def project_new_organisation_invite(invite, user)
    return false unless (@user = user).receive_notifications?

    @invite = invite
    mail to: @user.email, subject: "You've been invited to join a project on DigitalSocialInnovation"
  end

  def organisation_invite(user, organisation)
    return false unless (@user = user).receive_notifications?

    @organisation = organisation
    mail to: @user.email, subject: "You've been invited to join an organisation on DigitalSocialInnovation"
  end

  def request_digest(user, organisation)
    return false unless (@user = user).receive_notifications?

    @organisation = organisation
    mail to: @user.email, subject: "There are items awaiting your response on DigitalSocialInnovation for #{organisation.name}"
  end

  def project_request_acceptance(project_request, user)
    return false unless (@user = user).receive_notifications?

    @project_request = project_request
    @project = @project_request.project_resource
    @organisation = @project_request.requestor_organisation_resource

    mail to: @user.email, subject: "Your activity request has been accepted"
  end

  def user_request_acceptance(user_request, user)
    return false unless (@user = user).receive_notifications?

    @user_request = user_request
    @organisation = @user_request.organisation_resource

    mail to: @user.email, subject: "Your requst to join an organisation has been accepted"
  end

  def unconfirmed_user_reminder(user)
    @user = user

    mail to: @user.email, subject: "A reminder about your invitation to DigitalSocialInnovation"
  end

end
