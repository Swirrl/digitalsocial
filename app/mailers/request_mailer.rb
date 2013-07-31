class RequestMailer < ActionMailer::Base
  default from: "from@example.com"

  def project_new_organisation_invite(request)
    @request = request
    Rails.logger.debug "Sending project_new_organisation_invite email for Request ##{@request.id}"
  end

  def project_existing_organisation_invite(request)
    @request = request
    Rails.logger.debug "Sending project_existing_organisation_invite email for Request ##{@request.id}"
  end
end
