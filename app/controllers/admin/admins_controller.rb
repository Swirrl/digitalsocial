class Admin::AdminsController < AdminController

  before_filter :delete_password_from_params_if_blank, only: [:update]

  def edit
    @admin = current_admin
  end

  def update
    @admin = current_admin

    if @admin.update_attributes(params[:admin])
      redirect_to [:edit, :admin, current_admin], notice: "Profile updated!"
    else
      render :edit
    end
  end

  private

  def delete_password_from_params_if_blank
    params[:admin].delete(:password) if params[:admin][:password].blank? 
  end

end