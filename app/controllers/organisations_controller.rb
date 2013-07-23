class OrganisationsController < ApplicationController

  before_filter :authenticate_organisation!, except: [:new, :create]

  def new
    @organisation = Organisation.new
  end

  def create
    @organisation = Organisation.new(params[:organisation])

    if @organisation.save
      redirect_to root_path
    else
      render :new
    end
  end

end