class ProjectsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :find_project, only: [:invite, :invite_new_organisation, :invite_existing_organisation]

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

  def invite_new_organisation
    @project_invite = ProjectInvite.new
    @project_invite.attributes       = params[:project_invite]
    @project_invite.new_organisation = true
    @project_invite.project_uri      = @project.uri

    if @project_invite.save_for_new_organisation
      # TODO Send invitation email
      render text: "Invited new organisation!"
    else
      render :invite
    end
  end

  def invite_existing_organisation
    @project_invite = ProjectInvite.new
    @project_invite.attributes   = params[:project_invite]
    @project_invite.project_uri  = @project.uri

    if @project_invite.save_for_existing_organisation
      # TODO Send invitation email
      render text: "Invited existing organisation!"
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
  
end
