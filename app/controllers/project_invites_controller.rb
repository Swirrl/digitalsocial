class ProjectInvitesController < ApplicationController

  before_filter :authenticate_user!
  before_filter :set_invite, only: [:accept, :reject, :invite_via_suggestion]
  before_filter :ensure_permission_to_change_invite, only: [:accept, :reject, :invite_via_suggestion]
  
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
  def invite_via_suggestion
    @user = User.create_with_organisation_membership_from_project_invite @invite

    if @user.valid?
      RequestMailer.invite_via_suggestion @user, @invite, current_user

      @invite.set_invited_suggested_user!
      redirect_to :dashboard, notice: "#{@user.email} has been sent an invite"
    elsif account_has_been_claimed? @user
      @invite.set_invited_suggested_user!
      redirect_to :dashboard, notice: "This user has already been invited to Digital Social" 
    else
      redirect_to :dashboard, alert: "There was an error inviting #{@user.email}, please try again later." 
    end
  end
  
  private

  def set_invite
    @invite = ProjectInvite.find(params[:id])
  end

  def ensure_permission_to_change_invite
    unless @invite.invited_organisation_resource == current_organisation
      redirect_to :dashboard, alert: "You do not have permission to edit this resource."
    end
  end

  def account_has_been_claimed? user
    User.where(email: user.email).any?
  end  
end
