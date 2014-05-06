class PagesController < ApplicationController

  def show
    @page_category = PageCategory.find(params[:page_category_id])
    @page = @page_category.pages.find(params[:id])
    @title = @page.name
  end

  def index
    @page_category = PageCategory.find(params[:page_category_id])
    @pages = @page_category.pages
    @title = @page_category.name
  end

end
