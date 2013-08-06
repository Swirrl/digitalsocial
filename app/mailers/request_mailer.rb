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

  def project_request(request)
    @request = request
    mail to: @request.receiver.user.email, subject: "Project request"
  end

  def organisation_invite(request)
    @request = request
    mail to: @request.receiver.user.email, subject: "You have been added to an organisation"
  end
end
