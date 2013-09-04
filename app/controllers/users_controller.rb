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

    params[:user].delete(:password) if params[:user][:password].blank?

    if @user.update_attributes(params[:user])
      sign_in @user, bypass: true
      redirect_to edit_user_path # dashboard
    else
      render :edit
    end
  end

end
