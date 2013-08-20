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
    @organisation = SignupPresenter.new
  end

  def create_organisation
    @organisation = SignupPresenter.new
    @organisation.attributes = params[:signup_presenter]
    @organisation.user       = current_user

    if @organisation.save
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
      redirect_to [:organisations, :build, :invite_users]
    else
      render :edit_organisation
    end
  end

  def invite_users
    @organisation = current_organisation
  end

  def create_user_invites
    @organisation = current_organisation
  end

  private

  def redirect_to_new_organisation_if_logged_in
    redirect_to [:organisations, :build, :new_organisation] if user_signed_in?
  end

end