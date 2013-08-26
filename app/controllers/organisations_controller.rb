class OrganisationsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :set_organisation
  before_filter :ensure_user_is_organisation_owner, only: [:invite_user]

  # issue a request for the current user to join the org passed in the id.
  def request_to_join
    user_request = UserRequest.build_user_request(current_user, @organisation)

    if user_request.save
      # don't need to send an email. This will just appear in the digest.
      redirect_to user_url, :notice => "You have requested to join #{@organisation.name}. Members of #{@organisation.name} have be notified and we'll let you know when your request is accepted"
    else
      error_message = user_request.errors.messages.values.join(', ')
      redirect_to user_url, :notice => "Your request failed. #{error_message}"
    end
  end

  def edit
    @organisation = current_organisation
  end

  def update
    @organisation = current_organisation

    if @organisation.update_attributes(params[:organisation])
      redirect_to :user, notice: 'Organisation details updated.'
    else
      render :edit
    end
  end

  def edit_location
    @organisation = SignupPresenter.new(current_organisation)
  end

  def update_location
    @organisation = SignupPresenter.new(current_organisation)
    @organisation.attributes = params[:signup_presenter]

    if @organisation.save
      redirect_to :user, notice: 'Organisation location updated.'
    else
      render :edit_location
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
    if params[:q].present? # used for auto complete suggestions.
      @organisations = Organisation.search_by_name(params[:q]).to_a

      current_organisation_uris = current_user.organisation_resources.map{|o| o.uri.to_s }
      requested_organisation_uris = current_user.pending_join_org_requests.map(&:requestable).map{|o| o.uri.to_s }

    else
      @organisations = Organisation.all.resources.to_a
    end

    respond_to do |format|
      format.json do render json: {
          organisations: @organisations,
          current_organisation_uris: current_organisation_uris,
          requested_organisation_uris: requested_organisation_uris
        }
      end
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