class UsersController < ApplicationController

  def new
    @user = Signup.new
  end

  def create
    @user = Signup.new
    @user.attributes = params[:user]

    if @user.save
      render text: "Successfully signed up"
    else
      render :new
    end
  end
  
end
