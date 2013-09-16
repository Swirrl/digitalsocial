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

  private

  def set_title
    @title = params[:action].titleize
  end

end