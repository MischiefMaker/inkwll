class RoomsController < ApplicationController
  allow_previews only: %i[ index show ]

  def index
    # Every Place, grouped under its Area (Areas in the order of the front
    # page, sub-Areas beneath their parent). Rooms behind a numbered door are
    # reached from their building, so they aren't listed on their own.
    rooms_by_area = Room.listed.order(:name).group_by(&:area_id)
    @sections = []
    walk = ->(area, depth) do
      @sections << { area: area, depth: depth, rooms: rooms_by_area.fetch(area.id, []) }
      area.children.each { |child| walk.call(child, depth + 1) }
    end
    Area.top_level.each { |area| walk.call(area, 0) }
    @sections.reject! { |section| section[:rooms].empty? }
  end

  def show
    @room = Room.find(params[:id])
    if current_account
      use_remembered_character
    else
      session[:guest_token] ||= SecureRandom.hex(16)
      GuestVisit.note!(token: session[:guest_token], room: @room, user_agent: request.user_agent)
    end
  end

  private
    # If the player last used one of their characters here, and that character
    # is still in this room, switch back to it automatically. Otherwise, if the
    # active character is here, remember it for next time.
    def use_remembered_character
      remembered = current_account.remembered_character_for(@room)
      if remembered && remembered.room_id == @room.id && remembered != current_character
        current_account.update!(active_character: remembered)
      elsif current_character&.room_id == @room.id
        current_account.remember_character(current_character, @room)
      end
    end
end
