class ProjectInvitesController < ApplicationController

  before_filter :authenticate_user!
  before_filter :set_invite, only: [:accept, :reject]
  
  def accept
    @invite.attributes = params[:project_invite]

    if @invite.accept!
      redirect_to :user, notice: "The invite has been accepted."
    else
      redirect_to :user, alert: "The invite could not be accepted"
    end
  end

  def reject
    if @invite.reject!
      redirect_to :user
    else
      redirect_to :user
    end
  end

  private

  def set_invite
    # TODO Need to check current_organisation is allowed to accept/reject this invite
    @invite = ProjectInvite.find(params[:id])
  end

end
