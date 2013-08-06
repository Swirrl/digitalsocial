class OrganisationsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :set_organisation
  before_filter :ensure_user_is_organisation_owner, only: [:invite_user]

  def edit

  end

  def update
    if update_organisation
      redirect_to :projects
    else
      render :edit
    end
  end

  def user_invite
    @user_invite = UserInvite.new
  end

  def create_user_invite
    @user_invite = UserInvite.new
    @user_invite.attributes   = params[:user_invite]
    @user_invite.sender = current_organisation_membership

    if @user_invite.save
      render text: "User added"
    else
      render :user_invite
    end
  end

  private

  def set_organisation
    @organisation = current_organisation
  end

  def update_organisation
    transaction = Tripod::Persistence::Transaction.new

    @site = @organisation.primary_site_resource
    @site.lat = params[:lat]
    @site.lng = params[:lng]

    if @organisation.update_attributes(params[:organisation], transaction: transaction) && @site.save(transaction: transaction)
      transaction.commit
      true
    else
      transaction.abort
      false
    end
  end

  def ensure_user_is_organisation_owner
    redirect_to :projects unless current_organisation_membership.owner?
  end

end