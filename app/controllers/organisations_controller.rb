# -*- coding: utf-8 -*-
class OrganisationsController < ApplicationController

  before_filter :authenticate_user!, :except => [:index, :show, :map_index, :map_show, :map_partners, :map_partners_static, :map_cluster, :destroy]
  before_filter :set_organisation, :except => [:map_index, :map_show, :map_partners, :map_partners_static, :map_cluster]
  before_filter :ensure_user_is_organisation_owner, only: [:invite_user]
  before_filter :show_partners, only: [:show, :index]
  before_filter :authenticate_admin!, only: [:destroy]

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

  def destroy
    @organisation = Organisation.find(Organisation.slug_to_uri(params[:id]))
    @organisation.destroy

    redirect_to :organisations, notice: 'Organisation was removed.'
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

  def unjoin
    @organisation = Organisation.find(Organisation.slug_to_uri(params[:id]))

    if @organisation.only_user?(current_user)
      @organisation.unjoin(current_user)
      @organisation.destroy
      redirect_to [:edit, :user], notice: 'Organisation successfully removed.'
    else
      @organisation.unjoin(current_user)
      redirect_to [:edit, :user], notice: 'Organisation successfully unjoined.'
    end
  end

  def index

    if params[:q].present? # used for auto complete suggestions.
      @organisations = Organisation.search_by_name(params[:q]).to_a
      if params[:p].present?
        @project = Project.find( Project.slug_to_uri(params[:p]) )
        current_organisation_uris = @project.organisation_resources.map { |o| o.uri.to_s }
      else
        current_organisation_uris = current_user.organisation_resources.map { |o| o.uri.to_s }
      end
    else
      page = params[:page].present? ? params[:page].to_i : 1
      limit = Kaminari.config.default_per_page
      offset = (page - 1) * limit

      data = Organisation.order_by_name.limit(limit).offset(offset).resources.to_a
      total_count = Organisation.count

      @organisations = Kaminari.paginate_array(data, total_count: total_count).page(page).per(limit)
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
    config = {
      :organisation_type =>
        "?org <http://data.digitalsocial.eu/def/ontology/organizationType> ?organisation_type .",
      :activity_type =>
        "?am <http://data.digitalsocial.eu/def/ontology/organization> ?org .
         ?am <http://data.digitalsocial.eu/def/ontology/activity> ?activity .
         ?activity <http://data.digitalsocial.eu/def/ontology/activityType> ?activity_type .",
      :technology_focus =>
        "?am <http://data.digitalsocial.eu/def/ontology/organization> ?org .
         ?am <http://data.digitalsocial.eu/def/ontology/activity> ?activity .
         ?activity <http://data.digitalsocial.eu/def/ontology/technologyFocus> ?technology_focus .",
      :areas_of_society =>
        "?am <http://data.digitalsocial.eu/def/ontology/organization> ?org .
         ?am <http://data.digitalsocial.eu/def/ontology/activity> ?activity .
         ?activity <http://data.digitalsocial.eu/def/ontology/areaOfSociety> ?areas_of_society .",
      :country =>
        "?org <http://www.w3.org/ns/org#hasPrimarySite> ?primarySite .
         ?primarySite <http://www.w3.org/ns/org#siteAddress> ?siteAddress .
         ?siteAddress <http://www.w3.org/2006/vcard/ns#country-name> ?country"
    }

    #?activity <http://data.digitalsocial.eu/def/ontology/technologyFocus> ?techFocus

    extra_clauses = ""
    filters = ""

    if params[:filters].present?
      [:organisation_type, :activity_type, :technology_focus, :areas_of_society].each do |attr|
        if params[:filters][attr].present?
          extra_clauses += config[attr]
          filters += "VALUES ?#{attr.to_s} { <#{ params[:filters][attr].join('> <')}> }"
        end
      end

      if params[:filters][:country].present?
        extra_clauses += config[:country]
        filters += "VALUES ?country { '#{ params[:filters][:country].join("' '")}' }"
      end
    end

    query = "
      SELECT DISTINCT ?org ?orgType ?lat ?lng ?name WHERE {
        GRAPH <#{Digitalsocial::DATA_GRAPH}> {
          ?org a <http://www.w3.org/ns/org#Organization> ;
               <http://www.w3.org/ns/org#hasPrimarySite> ?site ;
               <http://www.w3.org/2000/01/rdf-schema#label> ?name .

          OPTIONAL {
            ?org <http://data.digitalsocial.eu/def/ontology/organizationType> ?orgType .
          }

          ?site <http://www.w3.org/2003/01/geo/wgs84_pos#lat> ?lat ;
                <http://www.w3.org/2003/01/geo/wgs84_pos#long> ?lng .

          #{ extra_clauses }
          #{ filters }
        }
      }
    "
    Rails.logger.debug query
    organisations = Tripod::SparqlClient::Query.select(query)

    Rails.logger.debug "http://data.digitalsocial.eu/sparql.csv?query=#{CGI.escape(query)}"

    respond_to do |format|
      format.json do
        render json: {
          organisations: organisations.map do |o|
            org = {
                   guid: o["org"]["value"].split('/').last,
                   name: o["name"]["value"],
                   lat: o["lat"]["value"],
                   lng: o["lng"]["value"]
                  }

            org[:type] = o["orgType"]["value"] if o["orgType"]
            org
          end
        }
      end
    end
  end

  def map_partners
    config = {
      :organisation_type =>
        "?org <http://data.digitalsocial.eu/def/ontology/organizationType> ?organisation_type .
         ?org2 <http://data.digitalsocial.eu/def/ontology/organizationType> ?organisation_type_2 .",
      :activity_type =>
        "?am <http://data.digitalsocial.eu/def/ontology/organization> ?org .
         ?am <http://data.digitalsocial.eu/def/ontology/activity> ?activity .
         ?activity <http://data.digitalsocial.eu/def/ontology/activityType> ?activity_type .
         ?am_2 <http://data.digitalsocial.eu/def/ontology/organization> ?org2 .
         ?am_2 <http://data.digitalsocial.eu/def/ontology/activity> ?activity .",
      :technology_focus =>
        "?am <http://data.digitalsocial.eu/def/ontology/organization> ?org .
         ?am <http://data.digitalsocial.eu/def/ontology/activity> ?activity .
         ?activity <http://data.digitalsocial.eu/def/ontology/technologyFocus> ?technology_focus .
         ?am_2 <http://data.digitalsocial.eu/def/ontology/organization> ?org2 .
         ?am_2 <http://data.digitalsocial.eu/def/ontology/activity> ?activity .",
      :areas_of_society =>
        "?am <http://data.digitalsocial.eu/def/ontology/organization> ?org .
         ?am <http://data.digitalsocial.eu/def/ontology/activity> ?activity .
         ?activity <http://data.digitalsocial.eu/def/ontology/areaOfSociety> ?areas_of_society .
         ?am_2 <http://data.digitalsocial.eu/def/ontology/organization> ?org2 .
         ?am_2 <http://data.digitalsocial.eu/def/ontology/activity> ?activity .",
      :country =>
        "?org <http://www.w3.org/ns/org#hasPrimarySite> ?primarySite .
         ?primarySite <http://www.w3.org/ns/org#siteAddress> ?siteAddress .
         ?siteAddress <http://www.w3.org/2006/vcard/ns#country-name> ?country .
         ?org2 <http://www.w3.org/ns/org#hasPrimarySite> ?primarySite_2 .
         ?primarySite_2 <http://www.w3.org/ns/org#siteAddress> ?siteAddress_2 .
         ?siteAddress_2 <http://www.w3.org/2006/vcard/ns#country-name> ?country_2 ."
    }

    extra_clauses = ""
    filters = ""

    if params[:filters].present?
      [:activity_type, :technology_focus, :areas_of_society].each do |attr|
        if params[:filters][attr].present?
          extra_clauses += config[attr]
          filters += "
            VALUES ?#{attr.to_s} { <#{ params[:filters][attr].join('> <')}> }"
        end
      end

      if params[:filters][:organisation_type].present?
        extra_clauses += config[:organisation_type]
        filters += "
            VALUES ?organisation_type { <#{ params[:filters][:organisation_type].join('> <')}> } .
            VALUES ?organisation_type_2 { <#{ params[:filters][:organisation_type].join('> <')}> }"
      end

      if params[:filters][:country].present?
        extra_clauses += config[:country]
        filters += "
            VALUES ?country { '#{ params[:filters][:country].join("' '")}' } .
            VALUES ?country_2 { '#{ params[:filters][:country].join("' '")}' }"
      end
    end

    query = "
      SELECT DISTINCT ?org ?org2 {
        ?mem a <http://data.digitalsocial.eu/def/ontology/ActivityMembership> .
        ?mem2 a <http://data.digitalsocial.eu/def/ontology/ActivityMembership> .

        ?mem <http://data.digitalsocial.eu/def/ontology/activity> ?proj .
        ?mem <http://data.digitalsocial.eu/def/ontology/organization> ?org .

        ?mem2 <http://data.digitalsocial.eu/def/ontology/activity> ?proj .
        ?mem2 <http://data.digitalsocial.eu/def/ontology/organization> ?org2 .

        ?org2 <http://www.w3.org/ns/org#hasPrimarySite> ?site2 .
        ?org <http://www.w3.org/ns/org#hasPrimarySite> ?site .

        #{ extra_clauses }
        #{ filters }
      }
      ORDER BY ASC(?org)
    "
    Rails.logger.debug query

    partner_guids_results = Tripod::SparqlClient::Query.select(query)

    partner_guids = {}
    partner_guids_results.each do |result|
      org_guid = result['org']['value'].split("/").last
      org2_guid = result['org2']['value'].split("/").last

      partner_guids[org_guid] ||= Set.new

      if org_guid != org2_guid
        partner_guids[org_guid] << (org2_guid)
      end
    end

    respond_to do |format|
      format.json do
        render json: {
          organisations: partner_guids
        }
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

  def map_cluster
    filter_clause = params[:guids].collect do |guid|
      "?uri = <#{Organisation.slug_to_uri(guid)}>"
    end.join(" || ")

    @organisations = Organisation.find_by_sparql(
      "SELECT ?uri ?label
      WHERE {
        ?uri <http://www.w3.org/2000/01/rdf-schema#label> ?label .
        ?uri a <http://www.w3.org/ns/org#Organization> .
        FILTER (
          #{filter_clause}
        )
      }
      ORDER BY ASC(lcase(str(?label)))"
    )

    respond_to do |format|
      format.json do
        render json: { organisations: @organisations.as_json(map_cluster: true) }
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
      redirect_to :dashboard, :notice => "You have requested to join #{@organisation.name}. Members of #{@organisation.name} have been notified and we'll let you know when your request is accepted"
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
