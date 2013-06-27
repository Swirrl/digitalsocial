class SiteController < ApplicationController

  before_filter :set_title, except: [:index]

  private

  def set_title
    @title = params[:action].titleize
  end
  
end