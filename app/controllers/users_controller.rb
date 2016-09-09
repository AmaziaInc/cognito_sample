class UsersController < ApplicationController
  include LoginHelper

  def new
  end

  def create
    result = login(params[:id_token])
    render :json => {identity_id: result.identity_id}
  end
end
