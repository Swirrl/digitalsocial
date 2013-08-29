class RequestMailer < ActionMailer::Base
  default from: "contact@digitialsocial.eu"

  def project_new_organisation_invite(invite, user)
    @invite = invite
    @user = user
    mail to: @user.email, subject: "Invitation"
  end

  def organisation_invite(user, organisation)
    @user = user
    @organisation = organisation
    mail to: @user.email, subject: "You have been added to an organisation"
  end

  def request_digest(user, organisation)
    @user = user
    @organisation = organisation
    mail to: @user.email, subject: "You have pending requests"
  end
end
