class UsersController < ApplicationController

  def new
  end

  def create
    render :json => {result: :ok}
  end
end
