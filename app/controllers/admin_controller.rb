class AdminController < ApplicationController

  before_filter :authenticate_admin!

  def toggle_help
    if session[:admin_hide_help].present?
      session.delete(:admin_hide_help)
    else
      session[:admin_hide_help] = '1'
    end

    redirect_to :back
  end

end