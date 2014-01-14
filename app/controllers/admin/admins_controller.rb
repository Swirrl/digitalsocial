class Admin::AdminsController < AdminController

  before_filter :delete_password_from_params_if_blank, only: [:update]

  def edit
    @admin = Admin.find(params[:id])
  end

  def update
    @admin = Admin.find(params[:id])

    if @admin.update_attributes(params[:admin])
      redirect_to [:edit, :admin, current_admin], notice: "Profile updated!"
    else
      render :edit
    end
  end

  def index
    @admins = Admin.all
  end

  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(params[:admin])

    if @admin.save
      redirect_to [:admin, :admins], notice: "Admin was created!"
    else
      render :new
    end
  end

  def destroy
    @admin = Admin.find(params[:id])

    if @admin.destroy
      redirect_to [:admin, :admins], notice: "Admin was deleted!"
    end
  end

  private

  def delete_password_from_params_if_blank
    params[:admin].delete(:password) if params[:admin][:password].blank? 
  end

end