class ProjectsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :find_project, only: [:invite, :create_invite, :edit, :update, :request_to_join, :create_request]
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

      current_projects = current_organisation.projects.resources
      requested_projects = current_organisation.pending_project_requests.map &:requestable

      @projects.reject!{ |p| current_projects.map(&:uri).include?(p.uri) } # don't include ones we're already a member of
      @projects.reject!{ |p| requested_projects.map(&:uri).include?(p.uri) } # don't include ones already requested to join

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

  def invite
    @project_invite = ProjectInvitePresenter.new
  end

  def new_invite

  end

  def create_invite
    if @project_invite.save
      render text: "Invited organisation!"
    else
      render :invite
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

  # get /projects/id/request_to_join
  def request_to_join
    @project_request = ProjectRequestPresenter.new
    @project_request.project_uri = @project.uri
    @project_request.organisation = current_organisation
  end

  def create_request
    @project_request = ProjectRequestPresenter.new
    @project_request.project_uri = @project.uri
    @project_request.organisation = current_organisation
    @project_request.nature_uris = params[:project_request_presenter][:nature_uris]

    # TODO? Store user details?

    if @project_request.save
      redirect_to user_url, notice: "Thanks for your request. This project's existing organisations will be notified and you'll be notified when someone approves your request."
    else
      flash.now.notice = @project_request.errors.messages.values.join(', ')
      render :request_to_join
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

  def set_project_invite
    @project_invite = ProjectInvitePresenter.new
    @project_invite.attributes   = params[:project_invite_presenter]
    @project_invite.project_uri  = @project.uri
  end

  def check_project_can_be_edited
    redirect_to user_url unless current_organisation.can_edit_project?(@project)
  end

end
