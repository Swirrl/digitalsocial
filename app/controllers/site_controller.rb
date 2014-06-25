class SiteController < ApplicationController

  before_filter :set_title, except: [:index]

  before_filter :show_partners, except: [:index]

  def index
    @selected_panel = params[:selected_panel] || 'welcome_panel'
    render layout: false
  end

  def events
    #@page = Page.where(path: 'events').first
  end

  def about
    @page = Page.where(_slugs: ["about"]).first
  end

  def resources
  end

  def community
  end

  def beta
    render layout: 'white'
  end

  private

  def set_title
    @title = params[:action].titleize
  end


end
