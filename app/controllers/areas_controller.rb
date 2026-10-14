# An Area page: the Areas and Settings inside it.
class AreasController < ApplicationController
  allow_previews
  def show
    @area = Area.find(params[:id])
  end
end
