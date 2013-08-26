class ProjectsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :find_project, only: [:invite, :create_new_org_invite, :create_existing_org_invite, :edit, :update, :request_to_join, :create_request, :new_invite]
  before_filter :set_project_invite, only: [:create_invite]
  before_filter :check_project_can_be_edited, only: [:edit, :update]

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

      # current_projects = current_organisation.projects.resources
      # requested_projects = current_organisation.pending_project_requests.map &:requestable

      # @projects.reject!{ |p| current_projects.map(&:uri).include?(p.uri) } # don't include ones we're already a member of
      # @projects.reject!{ |p| requested_projects.map(&:uri).include?(p.uri) } # don't include ones already requested to join

    else
      @projects = Project.all.resources.to_a
    end

    respond_to do |format|
      format.json { render json: @projects }
    end
  end

  def create
    @project = Project.new
    @project.scoped_organisation = current_organisation
    @project.creator             = current_organisation.uri

    if @project.update_attributes(params[:project])
      redirect_to :user, notice: "Project created!"
    else
      render :new
    end
  end

  def edit
    @project.scoped_organisation = current_organisation
  end

  def update
    @project.scoped_organisation = current_organisation

    if @project.update_attributes(params[:project])
      redirect_to :user, notice: "Project updated!"
    else
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
      redirect_to user_url, notice: "#{@project_request.project.name}'s organisations will be informed of your request. We'll let you know it's approved."
    else
      redirect_to user_url, alert: "Request failed. #{@project_request.errors.messages.values.join(', ')}"
    end
  end

  ##### INVITES #####

  # get /projects/:id/invite
  def invite
    @project_invite = ProjectInvitePresenter.new
    @project_invite.project_uri = @project.uri
    @project_invite.invitor_organisation_uri = current_organisation.uri
  end


  # GET /projects/:id/create_existing_org_invite?organisation_id=blah
  # One click invite
  # Should prob be a put or post but we want to generate the link in the JS suggestions.
  def create_existing_org_invite
    @project_invite = ProjectInvitePresenter.new
    @project_invite.project_uri = @project.uri
    @project_invite.invitor_organisation_uri = current_organisation.uri
    @project_invite.invited_organisation_uri = "http://data.digitalsocial.eu/id/organization/#{params[:organisation_id]}"

    if @project_invite.save
      redirect_to user_url, notice: "Organisation invited. Members of the organisation you invited will be notified."
    else
      Rails.logger.debug "Failed"
      flash.now[:alert] = "Invite failed. #{@project_invite.errors.messages.values.join(', ')}"
      render :invite
    end
  end

  # posting a form.
  def create_new_org_invite
    @project_invite = ProjectInvitePresenter.new
    @project_invite.attributes = params[:project_invite_presenter]
    @project_invite.project_uri = @project.uri
    @project_invite.invitor_organisation_uri = current_organisation.uri

    if @project_invite.save
      redirect_to user_url, notice: "Organisation invited. We'll email the contact you entered."
    else
      flash.now[:alert] = "Invite failed. #{@project_invite.errors.messages.values.join(', ')}"
      render :invite
    end

  end

  private

  def find_project
    Rails.logger.debug "finding: http://data.digitalsocial.eu/id/activity/#{params[:id]}"
    @project = Project.find("http://data.digitalsocial.eu/id/activity/#{params[:id]}")
  end

  def set_project_attributes
    params[:project].each { |k, v| @project.send("#{k}=", v) }
  end

  def check_project_can_be_edited
    redirect_to user_url unless current_organisation.can_edit_project?(@project)
  end

end
