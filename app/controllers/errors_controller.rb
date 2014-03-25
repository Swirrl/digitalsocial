class ErrorsController < ApplicationController
  def routing
    # just re-raise a tripod not found error. Handled in Application Controller
    raise Tripod::Errors::ResourceNotFound
  end
end