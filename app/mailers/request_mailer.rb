class RequestMailer < ActionMailer::Base
  default from: "from@example.com"

  def project_new_organisation_invite(request, user)
    @request = request
    @user = user
    mail to: @user.email, subject: "Invitation"
  end

  def organisation_invite(request)
    @request = request
    mail to: @request.receiver.user.email, subject: "You have been added to an organisation"
  end

  def request_digest(user)
    @user = user
    mail to: @user.email, subject: "You have pending requests"
  end
end
