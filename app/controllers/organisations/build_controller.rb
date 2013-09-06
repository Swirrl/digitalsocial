class Organisations::BuildController < ApplicationController

  before_filter :authenticate_user!, except: [:new_user, :create_user]
  before_filter :redirect_to_new_organisation_if_logged_in, only: [:new_user, :create_user]

  def new_user
    @user = User.new
  end

  def create_user
    @user = User.new(params[:user])

    if @user.save
      sign_in @user
      redirect_to [:organisations, :build, :new_organisation]
    else
      render :new_user
    end
  end

  def new_organisation
    @organisation = OrganisationPresenter.new
  end

  def create_organisation
    @organisation = OrganisationPresenter.new
    @organisation.attributes = params[:organisation_presenter]
    @organisation.user       = current_user

    if @organisation.save
      set_current_organisation( @organisation.organisation_guid ) # so that the following steps are for the righ org.
      redirect_to [:organisations, :build, :edit_organisation]
    else
      render :new_organisation
    end
  end

  def edit_organisation
    @organisation = current_organisation
  end

  def update_organisation
    @organisation = current_organisation

    if @organisation.update_attributes(params[:organisation])
      redirect_to [:organisations, :build, :new_project]
    else
      render :edit_organisation
    end
  end

  def new_project
    if (@project = current_organisation.project_resources.first).present?
      #redirect_to organisations_build_edit_project_path(id: @project.guid)
    end

    @project = Project.new
  end

  def create_project
    @project = Project.new
    @project.scoped_organisation = current_organisation
    @project.creator             = current_organisation.uri

    if @project.update_attributes(params[:project])
      redirect_to organisations_build_edit_project_path(id: @project.guid)
    else
      render :new_project
    end
  end

  def edit_project
    # TODO Ensure organisation is a member of the retrieved project
    @project = current_organisation.project_resources.first
    @project.scoped_organisation = current_organisation
  end

  def update_project
    # TODO Ensure organisation is a member of the retrieved project

    transaction = Tripod::Persistence::Transaction.new

    @project = Project.find(Project.slug_to_uri(params[:id]))
    @project.scoped_organisation = current_organisation

    if @project.update_attributes(params[:project], transaction: transaction ) && @project.save_reach_value(transaction: transaction)
      transaction.commit
      redirect_to organisations_build_invite_organisations_path(id: @project.guid)
    else
      transaction.abort
      render :edit_project
    end
  end

  def invite_organisations
    @project = Project.find(Project.slug_to_uri(params[:id]))
    @project_invite = ProjectInvitePresenter.new
    @project_invite.project_uri = @project.uri
    @project_invite.invitor_organisation_uri = current_organisation.uri
  end

  def create_new_organisation_invite
    @project = Project.find(Project.slug_to_uri(params[:id]))
    @project_invite = ProjectInvitePresenter.new
    @project_invite.attributes = params[:project_invite_presenter]
    @project_invite.project_uri = @project.uri
    @project_invite.invitor_organisation_uri = current_organisation.uri

    if @project_invite.save
      redirect_to dashboard_path, notice: "Organisation invited. We'll email the contact you entered."
    else
      flash.now[:alert] = "Invite failed. #{@project_invite.errors.messages.values.join(', ')}"
      render :invite_organisations
    end
  end

  private

  def redirect_to_new_organisation_if_logged_in
    redirect_to [:organisations, :build, :new_organisation] if user_signed_in?
  end

end