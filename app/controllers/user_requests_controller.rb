class UserRequestsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :set_request, only: [:accept, :reject]
  
  def index
    @user_invite = UserInvitePresenter.new
  end
  
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

  def create_invite
    @user_invite = UserInvitePresenter.new
    @user_invite.attributes   = params[:user_invite_presenter]
    @user_invite.organisation = current_organisation

    if @user_invite.save
      render text: "User invited"
    else
      render :index
    end
  end

  private

  def set_request
    # TODO Need to check current_organisation is allowed to accept/reject this request
    @request = UserRequest.find(params[:id])
  end

end
