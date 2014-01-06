class SiteController < ApplicationController

  before_filter :set_title, except: [:index]

  before_filter :show_partners, except: [:index]

  def index
    render layout: false
  end

  def about
    #raise Tripod::Errors::Timeout.new
    #foo trigger an error
  end

  def events
    @page = Page.where(path: 'events').first
  end

  def about
    @page = Page.where(path: 'about').first
  end

  def custom_page
    unless @page = Page.where(path: params[:path]).first
      raise Tripod::Errors::ResourceNotFound
    end
  end

  private

  def set_title
    @title = params[:action].titleize
  end

end