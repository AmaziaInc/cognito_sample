class SessionsController < ApplicationController
  include LoginHelper

  def new
  end

  def create
    result = login_with_cognito_identity
    # NOTE Do something to login.
    # session[:identity_id] = result.identity_id
    render :json => {identity_id: result.identity_id}
  end
end
