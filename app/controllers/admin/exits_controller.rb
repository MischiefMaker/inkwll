# Building tools: add and remove exits (Paths) from a room. Adding one can
# also create the matching return exit in the other room.
class Admin::ExitsController < Admin::BaseController
  require_job :build
  before_action :set_room

  def create
    @exit = @room.exits.new(params.expect(exit: [ :name, :direction, :number, :destination_room_id ]))
    return_name = params.dig(:exit, :return_name).to_s.squish
    # "Add the way back" with no name, on a Path with a direction, names it after the opposite direction.
    return_name = Exit::DIRECTIONS[Exit.opposite(@exit.direction)] if return_name.blank? && params.dig(:exit, :add_return) == "1" && @exit.direction.present?

    saved = Exit.transaction do
      @exit.save &&
        (return_name.blank? || save_return_exit(return_name)) || raise(ActiveRecord::Rollback)
    end

    if saved
      redirect_to edit_admin_room_path(@room), notice: return_name.present? ? "#{Term[:exit, count: 2]} added both ways." : "#{Term[:exit]} added."
    else
      redirect_to edit_admin_room_path(@room), alert: @exit.errors.full_messages.to_sentence
    end
  end

  def destroy
    @room.exits.find(params[:id]).destroy
    redirect_to edit_admin_room_path(@room), notice: "#{Term[:exit]} removed."
  end

  private
    def set_room
      @room = Room.find(params[:room_id])
    end

    def save_return_exit(name)
      # The way back points the opposite way: a Path north comes back south.
      return_exit = Exit.new(source_room: @exit.destination_room, destination_room: @room, name: name,
        direction: Exit.opposite(@exit.direction))
      return true if return_exit.save
      return_exit.errors.full_messages.each { |message| @exit.errors.add(:base, "Return #{Term[:exit].downcase}: #{message}") }
      false
    end
end
