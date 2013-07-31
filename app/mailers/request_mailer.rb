class RequestMailer < ActionMailer::Base
  default from: "from@example.com"

  def project_new_organisation_invite(request)
    @request = request
    mail to: @request.receiver.user.email, subject: "Invitation"
  end

  def project_existing_organisation_invite(request)
    @request = request
    mail to: @request.receiver.user.email, subject: "Invitation"
  end
end
