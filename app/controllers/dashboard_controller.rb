class DashboardController < ApplicationController

  before_filter :authenticate_user!
  # before_filter :redirect_to_new_organisation_if_no_organisation

  def projects
    
  end

  private

  def redirect_to_new_organisation_if_no_organisation
    redirect_to [:organisations, :build, :new_organisation] unless current_user.any_organisations?
  end

end