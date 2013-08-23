class ProjectsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :find_project, only: [:invite, :create_invite, :edit, :update]
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
    if params[:q].present?
      @projects = Project.search_by_name(params[:q]).to_a
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

  def create_request
    @project_request = ProjectRequestPresenter.new
    @project_request.attributes   = params[:project_request_presenter]
    @project_request.organisation = current_organisation

    if @project_request.save
      render text: "Requested to be part of project"
    else
      @project = Project.new
      render :new
    end
  end

  private

  def find_project
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
