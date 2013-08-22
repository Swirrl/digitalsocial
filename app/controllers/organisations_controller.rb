class OrganisationsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :set_organisation
  before_filter :ensure_user_is_organisation_owner, only: [:invite_user]

  def edit

  end

  # issue a request for the current user to join the org passed in the id.
  def request_to_join
    user_request = UserRequest.build_user_request(current_user, @organisation)

    if user_request.save
      # TODO send email.
      respond_to do |format|
        format.html { render :text => 'success' } # for testing really
        format.js { render :json => {:success => true }}
      end
    else
      error_message = user_request.errors.messages.values.join(', ')
      respond_to do |format|
        format.html { render :text => error_message } # for testing really
        format.js { render :json => {:success => false, :errorMessage => error_message } }
      end

    end
  end

  def update
    if update_organisation
      redirect_to user
    else
      render :edit
    end
  end

  def user_invite
    @user_invite = UserInvitePresenter.new
  end

  def create_user_invite
    @user_invite = UserInvitePresenter.new
    user_invite_parameters = params[:user_invite_presenter]

    @user_invite.user_first_name = user_invite_parameters[:user_first_name]
    @user_invite.user_email = user_invite_parameters[:user_email]
    @user_invite.organisation = @organisation

    if @user_invite.save
      render text: "User added"
    else
      render :user_invite
    end
  end

  def index
    if params[:q].present?
      # TODO Find orgs by name/location etc.
      @organisations = Organisation.search_by_name(params[:q]).to_a
    else
      @organisations = Organisation.all.resources.to_a
    end

    respond_to do |format|
      format.json { render json: @organisations }
    end
  end

  private

  def set_organisation
    if params[:id].present?
      @organisation = Organisation.find("http://data.digitalsocial.eu/id/organization/#{params[:id]}")
    else
      @organisation = current_organisation
    end
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