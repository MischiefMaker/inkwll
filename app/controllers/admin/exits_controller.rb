# Building tools: add, edit and remove exits (Paths) from a room. Adding one can
# also create the matching return exit in the other room.
class Admin::ExitsController < Admin::BaseController
  require_job :build
  before_action :set_room

  def create
    @exit = @room.exits.new(exit_params)
    @exit.kind = Exit.kind_for(@exit.destination_room) if @exit.kind.blank?
    return_name = params.dig(:exit, :return_name).to_s.squish
    # "Add the way back" with no name names it after its direction: the
    # opposite way on a street, Out from a building or unit.
    return_direction = Exit.opposite(@exit.direction, kind: @exit.kind)
    return_name = Exit::DIRECTIONS[return_direction] if return_name.blank? && params.dig(:exit, :add_return) == "1" && return_direction

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

  def edit
    @exit = @room.exits.find(params[:id])
  end

  def update
    @exit = @room.exits.find(params[:id])
    @exit.assign_attributes(exit_params)
    @exit.kind = Exit.kind_for(@exit.destination_room) if @exit.kind.blank?
    if @exit.save
      redirect_to edit_admin_room_path(@room), notice: "#{Term[:exit]} saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @room.exits.find(params[:id]).destroy
    redirect_to edit_admin_room_path(@room), notice: "#{Term[:exit]} removed."
  end

  private
    def exit_params
      params.expect(exit: [ :name, :kind, :direction, :number, :destination_room_id ])
    end

    def set_room
      @room = Room.find(params[:room_id])
    end

    def save_return_exit(name)
      # The way back points the opposite way: a Path north comes back south,
      # and the way out of a building is Out. It's always a street.
      return_exit = Exit.new(source_room: @exit.destination_room, destination_room: @room, name: name,
        direction: Exit.opposite(@exit.direction, kind: @exit.kind))
      return true if return_exit.save
      return_exit.errors.full_messages.each { |message| @exit.errors.add(:base, "Return #{Term[:exit].downcase}: #{message}") }
      false
    end
end
