class UsersController < ApplicationController

  def new
    @user = Signup.new
  end

  def create
    @user = Signup.new
    @user.attributes = params[:user]

    if @user.save
      sign_in @user.user
      redirect_to :projects
    else
      render :new
    end
  end
  
end
