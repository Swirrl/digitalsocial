class InvalidTreeType < StandardError ; end

class TreeViewController < ApplicationController

  respond_to :json

  def show
    klass = if params[:type] == 'organisation'
              Organisation
            elsif params[:type] == 'project'
              Project
            else
              raise InvalidTreeType, 'Invalid Tree Type'
            end

    resource_uri = klass.slug_to_uri params[:id]
    @resource = klass.find resource_uri

    @tree = TreeData.new @resource, 2, @resource

    respond_with @tree.to_json
  end
end
