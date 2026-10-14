# "My places": Settings a player has saved, to travel back to in one click.
# Saving and unsaving happens on a Setting's page.
class SavedPlacesController < ApplicationController
  before_action :set_room, only: %i[ create destroy ]

  def index
    @places = current_account.saved_places.includes(room: :area).sort_by { |place| place.room.name }
  end

  def create
    current_account.saved_places.find_or_create_by!(room: @room)
    redirect_to room_path(@room), notice: "Saved to My places."
  end

  def destroy
    current_account.saved_places.where(room: @room).delete_all
    redirect_back fallback_location: room_path(@room), notice: "Removed from My places."
  end

  private
    def set_room
      @room = Room.find(params[:room_id])
    end
end
