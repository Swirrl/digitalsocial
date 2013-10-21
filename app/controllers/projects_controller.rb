# -*- coding: utf-8 -*-
class ProjectsController < ApplicationController

  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :find_project, only: [:invite, :create_new_org_invite, :create_existing_org_invite, :edit, :update, :request_to_join, :create_request, :new_invite]
  before_filter :set_project_invite, only: [:create_invite]
  before_filter :check_project_can_be_edited, only: [:edit, :update]
  before_filter :show_partners, only: [:show, :index]


  # expects a top-level activity type label as a param.
  # returns the reach question text
  def reach_question_text
    slug = Concepts::ActivityType.slugify_label_text(params[:activity_type_label])
    activity_type_resource = Concepts::ActivityType.find( Concepts::ActivityType.uri_from_slug(slug) )
    render :text => activity_type_resource.get_reach_question_text
  end

  # return tags for the tagit controls
  # expects a tag_class param with the name of the tag class to query
  # expects a term param with the search term
  def tags
    klass = Object.const_get("Concepts").const_get(params[:tag_class])
    results = klass.search_for_label_starting_with(params[:term]).map &:label
    render :json => results.uniq.sort
  end

  def new
    @project = Project.new
    @project_request = ProjectRequestPresenter.new
  end

  def index
    if params[:q].present? # used for auto complete suggestions.
      @projects = Project.search_by_name(params[:q]).to_a
      current_project_uris = current_organisation.project_resource_uris
    else
      page = params[:page].present? ? params[:page].to_i : 1
      limit = Kaminari.config.default_per_page
      offset = (page - 1) * limit

      data = Project.order_by_name.limit(limit).offset(offset).resources.to_a
      total_count = Project.count

      @projects = Kaminari.paginate_array(data, total_count: total_count).page(page).per(limit)
    end

    respond_to do |format|
      format.json do render json: {
          projects: @projects,
          current_project_uris: current_project_uris
        }
      end
      format.html
    end

  end

  def show
    @project = Project.find( Project.slug_to_uri(params[:id]) )
  end

  def create
    transaction = Tripod::Persistence::Transaction.new
    @project = Project.new
    @project.scoped_organisation = current_organisation
    @project.creator             = current_organisation.uri

    if @project.update_attributes(params[:project], transaction: transaction) && @project.save_reach_value(transaction: transaction)
      transaction.commit
      redirect_to [:invite, @project], notice: "Activity was created. Use the form below to invite an organisation you worked with on this activity."
    else
      transaction.abort
      render :new
    end
  end

  def edit
    @project.scoped_organisation = current_organisation
  end

  def update
    transaction = Tripod::Persistence::Transaction.new

    @project.scoped_organisation = current_organisation

    if @project.update_attributes(params[:project], transaction: transaction) && @project.save_reach_value(transaction: transaction)
      transaction.commit
      redirect_to [:dashboard, :projects], notice: "Activity successfully updated"
    else
      transaction.abort
      render :edit
    end
  end


  ##### REQUESTS #####

  # GET /projects/:id/request_to_join.
  # One click request (from suggestions or project page).
  # Should prob be a put or post but we want to generate the link in the JS suggestions.
  def request_to_join
    @project_request = ProjectRequestPresenter.new
    @project_request.project_uri = @project.uri
    @project_request.requestor_organisation_uri = current_organisation.uri

    if @project_request.save
      redirect_to [:dashboard, :projects], notice: "#{@project_request.project.name}'s organisations will be informed of your request. We'll let you know when it's approved."
    else
      redirect_to [:dashboard, :projects], alert: "Request failed. #{@project_request.errors.messages.values.join(', ')}"
    end
  end

  ##### INVITES #####

  # prepare to invite a new org to a project
  # get /projects/:id/invite
  def invite
    @project_invite = ProjectInvitePresenter.new
    @project_invite.project_uri = @project.uri
    @project_invite.invitor_organisation_uri = current_organisation.uri
  end

  # Actually invite an existing org to a project
  # GET /projects/:id/create_existing_org_invite?organisation_id=blah
  # One click invite
  # Should prob be a put or post but we want to generate the link in the JS suggestions.
  def create_existing_org_invite
    @project_invite = ProjectInvitePresenter.new
    @project_invite.project_uri = @project.uri
    @project_invite.invitor_organisation_uri = current_organisation.uri
    @project_invite.invited_organisation_uri = Organisation.slug_to_uri(params[:organisation_id])

    if @project_invite.save
      redirect_to [:dashboard, :projects], notice: "Organisation invited. Members of the organisation you invited will be notified."
    else
      Rails.logger.debug "Failed"
      flash.now[:alert] = "Invite failed. #{@project_invite.errors.messages.values.join(', ')}"
      render :invite
    end
  end

  # Actually invite a new org to a project
  # posting a form.
  def create_new_org_invite
    @project_invite = ProjectInvitePresenter.new
    @project_invite.attributes = params[:project_invite_presenter]
    @project_invite.project_uri = @project.uri
    @project_invite.invitor_organisation_uri = current_organisation.uri
    @project_invite.invited_by_user = current_user

    if @project_invite.save
      redirect_to [:dashboard, :projects], notice: "Organisation invited. We'll email the contact you entered."
    else
      flash.now[:alert] = "Invite failed. #{@project_invite.errors.messages.values.join(', ')}"
      render :invite
    end

  end

  private

  def find_project
    @project = Project.find(Project.slug_to_uri(params[:id]))
  end

  def set_project_attributes
    params[:project].each { |k, v| @project.send("#{k}=", v) }
  end

  def check_project_can_be_edited
    redirect_to dashboard_projects_path unless current_organisation.can_edit_project?(@project)
  end

end
