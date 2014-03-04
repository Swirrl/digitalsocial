class Admin::UsersController < AdminController

  def index
    @users = User.all

    respond_to do |format|
      format.html
      format.csv do 
        send_data User.to_csv, filename: "dsi-users-#{Time.now.strftime("%d%b%Y")}"
      end
    end
  end

end