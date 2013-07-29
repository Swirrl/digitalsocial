class ProjectsController < ApplicationController

  before_filter :authenticate_user!

  def new
    @project = Project.new
  end

  def index
    redirect_to [:new, :project] unless current_user.projects.any?
  end

  def create
    @project = Project.new

    if @project.update_attributes(params[:project])
      @project.create_time_interval!
      @project.create_lead_membership!(current_organisation)
      render text: "Success"
    else
      render :new
    end
  end
  
end
