class OrganisationsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :set_organisation

  def edit

  end

  def update
    if update_organisation
      redirect_to :projects
    else
      render :edit
    end
  end

  private

  def set_organisation
    @organisation = current_organisation
  end

  def update_organisation
    transaction = Tripod::Persistence::Transaction.new

    @site = @organisation.primary_site_resource
    @site.lat = params[:lat]
    @site.lng = params[:lng]

    if @organisation.update_attributes(params[:organisation], transaction: transaction) && @site.save(transaction: transaction)
      transaction.commit
      true
    else
      transaction.abort
      false
    end
  end

end