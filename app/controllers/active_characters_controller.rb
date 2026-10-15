# The character switcher dropdown in the page header.
class ActiveCharactersController < ApplicationController
  # "gm" switches staff and Storytellers to posting as their player. Going
  # to or from GM keeps you on the page you're on, since GM isn't anywhere;
  # switching between characters takes you to where the new one is.
  def update
    was_gm = current_character&.gm?
    if params[:character_id] == "gm"
      return redirect_back fallback_location: root_path, alert: "Only staff and #{Term[:storyteller].pluralize} can play as GM." unless current_account.may_storytell?
      here = current_character&.room
      character = current_account.gm!
      character.update!(room: here) if here && character.room_id != here.id
      switch_staying_put(character)
      return redirect_back fallback_location: room_path(character.room), notice: "You are now posting as GM, under your player name."
    end

    character = current_account.characters.active.find(params[:character_id])
    if was_gm
      switch_staying_put(character)
      redirect_back fallback_location: room_path(character.room), notice: "You are now playing #{character.name}."
    else
      current_account.switch_to(character)
      redirect_to room_path(character.room), notice: "You are now playing #{character.name}."
    end
  end

  private
    # Makes the character active and remembers the choice for the Setting or
    # Chapter page being looked at, so that page doesn't switch straight back
    # to whoever was remembered there.
    def switch_staying_put(character)
      current_account.update!(active_character: character)
      context = page_context
      current_account.remember_character(character, context) if context
    end

    def page_context
      route = Rails.application.routes.recognize_path(URI(request.referer.to_s).path)
      case route[:controller]
      when "rooms" then Room.find_by(id: route[:id]) if route[:action] == "show"
      when "scenes" then Scene.find_by(id: route[:id]) if route[:action] == "show"
      end
    rescue ActionController::RoutingError, URI::InvalidURIError
      nil
    end
end
