class AdminController < ApplicationController

  before_filter :authenticate_admin!

  def toggle_help
    if session[:admin_help].present?
      session.delete(:admin_help)
    else
      session[:admin_help] = '1'
    end

    redirect_to :back
  end

end