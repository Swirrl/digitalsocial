class RequestMailer < ActionMailer::Base
  default from: "contact@digitalsocial.eu"

  def project_new_organisation_invite(invite, user)
    return false unless (@user = user).receive_notifications?

    @invite = invite
    @invitor_organisation = invite.invitor_organisation
    @project = invite.project
    mail to: @user.email, subject: "You've been invited to join a project on DigitalSocialInnovation"
  end

  def organisation_invite(user, organisation)
    return false unless (@user = user).receive_notifications?

    @organisation = organisation
    mail to: @user.email, subject: "You've been invited to join an organisation on DigitalSocialInnovation"
  end

  # the user is being invited by an existing organisation member on
  # the suggestion of a 3rd party project invite.
  def invite_via_suggestion(invited_user, project_invite, authorised_by_user)
    return false unless (@invited_user = invited_user).receive_notifications?

    @organisation = project_invite.invited_organisation_resource
    @invited_user = project_invite.invited_user
    @authorised_by_user_name = authorised_by_user.first_name.blank? ? 'Someone' : authorised_by_user.first_name
    @authorised_by_user_email = authorised_by_user.email
    
    mail to: @invited_user.email, subject: "You've been invited to join an organisation on DigitalSocialInnovation"
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

    mail to: @user.email, subject: "Your project request has been accepted"
  end

  def user_request_acceptance(user_request, user)
    return false unless (@user = user).receive_notifications?

    @user_request = user_request
    @organisation = @user_request.organisation_resource

    mail to: @user.email, subject: "Your request to join an organisation has been accepted"
  end

  def unconfirmed_user_reminder(user)
    @user = user

    mail to: @user.email, subject: "A reminder about your invitation to DigitalSocialInnovation"
  end

  def projectless_user_reminder(user, organisation)
    return false unless (@user = user).receive_notifications?
    
    @organisation = organisation

    mail to: @user.email, subject: "A reminder about your DigitalSocialInnovation account"
  end

end
