class OrganisationsController < ApplicationController

  before_filter :authenticate_user!, :except => [:index, :show, :map_index, :map_show]
  before_filter :set_organisation, :except => [:map_index, :map_show]
  before_filter :ensure_user_is_organisation_owner, only: [:invite_user]

  def edit
    @organisation = current_organisation
  end

  def update
    @organisation = current_organisation

    if @organisation.update_attributes(params[:organisation])
      redirect_to [:edit, @organisation], notice: 'Organisation details updated.'
    else
      Rails.logger.debug @organisation.errors.inspect
      render :edit
    end
  end

  def edit_location
    @organisation = OrganisationPresenter.new(current_organisation)
  end

  def update_location
    @organisation = OrganisationPresenter.new(current_organisation)
    @organisation.attributes = params[:organisation_presenter]

    if @organisation.save
      redirect_to [:edit_location, current_organisation], notice: 'Organisation location updated.'
    else
      render :edit_location
    end
  end

  def show
    @organisation = Organisation.find( Organisation.slug_to_uri(params[:id]) )
  end

  def index
    org_name_predicate = 

    if params[:q].present? # used for auto complete suggestions.
      @organisations = Organisation.search_by_name(params[:q]).to_a
      current_organisation_uris = current_user.organisation_resources.map{|o| o.uri.to_s }
    else
      @organisations = Organisation.order_by_name.resources
    end

    respond_to do |format|
      format.json do render json: {
          organisations: @organisations,
          current_organisation_uris: current_organisation_uris # list of orgs for this user
        }
      end
      format.html
    end
  end

  def map_index
    @organisations = Organisation.all.resources

    respond_to do |format|
      format.json do
        render json: { organisations: @organisations.as_json(map_index: true) }
      end
    end
  end
  
  def map_show
    @organisation = Organisation.find(Organisation.slug_to_uri(params[:id]))

    respond_to do |format|
      format.json do
        render json: { organisation: @organisation.as_json(map_show: true) }
      end
    end
  end

  ##### REQUESTS ####

  # issue a request for the current user to join the org passed in the id.
  def request_to_join
    user_request = UserRequest.new
    user_request.user = current_user
    user_request.organisation_uri = @organisation.uri.to_s

    if user_request.save
      redirect_to :dashboard, :notice => "You have requested to join #{@organisation.name}. Members of #{@organisation.name} have be notified and we'll let you know when your request is accepted"
    else
      error_message = user_request.errors.messages.values.join(', ')
      redirect_to :dashboard, :notice => "Your request failed. #{error_message}"
    end
  end

  ##### INVITES ####

  def invite_users
    @organisation = current_organisation
    @organisation.build_user_invites
  end

  def create_user_invites
    @organisation = current_organisation
    @organisation.invited_users = params[:invited_users]

    if @organisation.can_send_user_invites?
      @organisation.send_user_invites
      redirect_to [:dashboard, :users], notice: "Team members invited"
    else
      render :invite_users
    end
  end

  private

  def set_organisation
    if current_user
      if params[:id].present?
        @organisation = Organisation.find(Organisation.slug_to_uri(params[:id]))
      else
        @organisation = current_organisation
      end
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