class ProjectsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :find_project, only: [:invite, :create_invite]
  before_filter :set_project_invite, only: [:create_invite]

  def new
    @project = Project.new
  end

  def index
    redirect_to [:new, :project] unless current_organisation.any_projects?

    @projects = current_organisation.projects.resources
  end

  def create
    @project = Project.new

    if @project.update_attributes(params[:project])
      @project.create_time_interval!
      @project.add_creator_membership!(current_organisation)
      redirect_to :projects
    else
      render :new
    end
  end

  def invite
    @project_invite = ProjectInvite.new
  end

  def create_invite
    if @project_invite.save
      render text: "Invited organisation!"
    else
      render :invite
    end
  end

  private

  def find_project
    @project = Project.find("http://example.com/project/#{params[:id]}")
  end

  def set_project_attributes
    params[:project].each { |k, v| @project.send("#{k}=", v) }
  end

  def set_project_invite
    @project_invite = ProjectInvite.new
    @project_invite.attributes   = params[:project_invite]
    @project_invite.sender       = current_organisation_membership
    @project_invite.project_uri  = @project.uri
  end
  
end
