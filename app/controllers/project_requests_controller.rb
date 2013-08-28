class ProjectRequestsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :set_request, only: [:accept, :reject]
  
  def accept
    @request.attributes = params[:project_request]

    if @request.accept!
      redirect_to :user, notice: "The request has been accepted."
    else
      redirect_to :user, alert: "The request could not be accepted"
    end
  end

  def reject
    if @request.reject!
      redirect_to :user
    else
      redirect_to :user
    end
  end

  private

  def set_request
    # TODO Need to check current_organisation is allowed to accept/reject this request
    @request = ProjectRequest.find(params[:id])
  end

end
