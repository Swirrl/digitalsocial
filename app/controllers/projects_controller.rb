class ProjectsController < ApplicationController

  before_filter :authenticate_user!

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
  
end
