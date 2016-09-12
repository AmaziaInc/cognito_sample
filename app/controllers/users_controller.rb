class UsersController < ApplicationController
  include LoginHelper

  def new
  end

  def create
    result = login_with_cognito_identity
    # NOTE Do something to register. Create user, send registration email, etc.
    render :json => {identity_id: result.identity_id}
  end
end
