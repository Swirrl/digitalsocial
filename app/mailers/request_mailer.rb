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
    mail to: @user.email, subject: "You've been invited to join ab organisation on DigitalSocialInnovation"
  end

  def request_digest(user, organisation)
    @user = user
    @organisation = organisation
    mail to: @user.email, subject: "There are items awaiting your response on DigitalSocialInnovation for #{organisation.name}"
  end
end
