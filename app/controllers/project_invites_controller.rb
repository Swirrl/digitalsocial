class ProjectInvitesController < ApplicationController

  before_filter :authenticate_user!
  before_filter :set_invite, only: [:accept, :reject, :delegate]
  
  def accept
    @invite.attributes = params[:project_invite]

    if @invite.accept!
      redirect_to :dashboard, notice: "The invite has been accepted."
    else
      redirect_to :dashboard, alert: "The invite could not be accepted"
    end
  end

  def reject
    if @invite.reject!
      redirect_to :dashboard
    else
      redirect_to :dashboard
    end
  end

  # PUT :id/delegate
  #
  # invites the suggested user
  def delegate
    render text: 'TODO'
  end
  
  private

  def set_invite
    @invite = ProjectInvite.find(params[:id])

    unless @invite.invited_organisation_resource == current_organisation
      redirect_to :dashboard, alert: "You do not have permission to edit this resource."
    end
  end

end
