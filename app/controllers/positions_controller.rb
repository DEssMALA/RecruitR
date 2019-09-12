class PositionsController < ApplicationController
  def index
  end

  def new
  end

  def create
    render plain: params[:position].inspect
  end

end
