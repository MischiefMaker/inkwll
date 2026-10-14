# An Area page: the Areas and Settings inside it.
class AreasController < ApplicationController
  def show
    @area = Area.find(params[:id])
  end
end
