class Admin::PageCategoriesController < AdminController

  def index
    @page_categories = PageCategory.all
  end

  def edit
    @page_category = PageCategory.find(params[:id])
  end

  def update
    @page_category = PageCategory.find(params[:id])

    if @page_category.update_attributes(params[:page_category])
      redirect_to [:admin, :page_categories], notice: "Page category was updated!"
    else
      render :edit
    end
  end

end