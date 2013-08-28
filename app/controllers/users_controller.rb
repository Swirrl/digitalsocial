class UsersController < ApplicationController

  before_filter :authenticate_user!, only: [:show, :edit_invited, :update_invited, :edit, :update]

  # user dashboard
  def show
    #redirect_to [:organisations, :build, :new_organisation] unless current_organisation
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      redirect_to new_organisation_index_path
    else
      render :new
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update_attributes(params[:user])
      sign_in @user, bypass: true
      redirect_to user_url # dashboard
    else
      render :edit
    end
  end

  def edit_invited
    @user = SignupPresenter.new
    @user.first_name        = current_user.first_name
    @user.email             = current_user.email
    @user.organisation_name = current_organisation.name
  end

  def update_invited
    @user = SignupPresenter.new
    @user.attributes = params[:user]

    # TODO Move this into presenter
    @user.user            = current_user
    @user.user.first_name = @user.first_name
    @user.user.email      = @user.email
    @user.user.password   = @user.password

    @user.organisation              = current_organisation
    @user.organisation.name         = @user.organisation_name
    @user.organisation.primary_site = @user.site.uri

    @user.organisation_membership = current_organisation_membership

    if @user.save
      sign_in @user.user, bypass: true
      redirect_to user_url # dashboard
    else
      render :edit_invited
    end
  end

end
