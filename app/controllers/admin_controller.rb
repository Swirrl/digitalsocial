class AdminController < ApplicationController

  before_filter :authenticate_admin!

end