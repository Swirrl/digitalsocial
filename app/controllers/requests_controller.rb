class RequestsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :set_request, only: [:accept, :reject]
  
  def accept
    if @request.accept!
      redirect_to @request.requestable
    else
      redirect_to :back, alert: "Your request could not be accepted"
    end
  end

  def reject
    if @request.reject!
      redirect_to :back, notice: "The request has been rejected."
    else
      redirect_to :back, alert: "Your request could not be reject."
    end
  end

  private

  def set_request
    @request = current_organisation_membership.requests.find(params[:id])
  end

end
