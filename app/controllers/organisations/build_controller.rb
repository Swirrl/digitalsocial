class Organisations::BuildController < ApplicationController

  before_filter :authenticate_user!, except: [:new_user, :create_user]

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
    
  end

end