class SiteController < ApplicationController

  before_filter :set_title, except: [:index]

  def index
    render layout: false
  end

  def terms
    
  end

  private

  def set_title
    @title = params[:action].titleize
  end
  
end