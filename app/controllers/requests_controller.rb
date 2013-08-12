class RequestsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :set_request, only: [:accept, :reject]
  
  def accept
    if @request.accept!
      redirect_to :back, notice: "The request has been accepted."
    else
      redirect_to :back, alert: "The request could not be accepted"
    end
  end

  def reject
    if @request.reject!
      redirect_to :back, notice: "The request has been rejected."
    else
      redirect_to :back, alert: "The request could not be rejected."
    end
  end

  private

  def set_request
    # TODO Need to check current_organisation is allowed to accept/reject this request
    @request = Request.find(params[:id])
  end

end
