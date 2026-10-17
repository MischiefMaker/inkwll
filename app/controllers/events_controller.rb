# The event calendar. Anyone can read it; players with an approved character
# host events as that character, and the host or building staff change or
# cancel them. Times are typed in the player's own time zone.
class EventsController < ApplicationController
  allow_previews only: %i[ index show ]
  limit_posting to: 5, within: 1.hour, only: :create
  before_action :set_event, only: %i[ show edit update destroy ]
  before_action :require_changer, only: %i[ edit update destroy ]
  before_action :require_host_choices, only: %i[ new create ]

  def index
    Event.open_due!
    @upcoming = Event.upcoming.includes(:room, :host, :signups)
    @recent = Event.recent.includes(:room, :host, :scene)
  end

  def show
    Event.open_due! if @event.starts_at <= Time.current
    @event.reload
    @signups = @event.signups.includes(character: [ :character_group, { icon_attachment: :blob } ]).order(:created_at)
    @choices = @event.signup_choices_for(current_account)
  end

  def new
    @event = Event.new(room: current_character&.room, starts_at: 1.week.from_now.change(min: 0))
  end

  def create
    @event = Event.new(event_params.merge(created_by: current_account, host: chosen_host))
    if @event.save
      redirect_to @event, notice: "On the calendar."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.opened? || @event.cancelled?
      return redirect_to @event, alert: "This event has already #{@event.cancelled? ? "been cancelled" : "started"}."
    end
    if @event.update(event_params)
      redirect_to @event, notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Cancelling keeps the event on the calendar for a while, marked cancelled.
  def destroy
    @event.cancel! unless @event.opened?
    redirect_to events_path, notice: "#{@event.title} is cancelled."
  end

  private
    def set_event
      @event = Event.find(params[:id])
    end

    def require_changer
      redirect_to @event, alert: "Only the host and staff can change this event." unless @event.changeable_by?(current_account)
    end

    def require_host_choices
      @hosts = current_account.characters.active.order(:name).select(&:can_play?)
      redirect_to events_path, alert: "You need an approved character to host an event." if @hosts.empty?
    end

    def chosen_host
      @hosts.find { |character| character.id == params.dig(:event, :host_id).to_i }
    end

    def event_params
      attrs = params.expect(event: [ :title, :description, :room_id, :starts_at ])
      attrs[:room_id] = nil unless Room.listed.exists?(id: attrs[:room_id])
      attrs[:starts_at] = in_players_zone(attrs[:starts_at]) if attrs.key?(:starts_at)
      attrs
    end

    # The form sends the time as the player typed it plus their browser's
    # offset from UTC in minutes (the way JavaScript gives it), so everyone
    # sees the event at the right moment in their own time zone.
    def in_players_zone(typed)
      local = Time.find_zone("UTC").parse(typed.to_s) or return
      local + params[:utc_offset].to_i.clamp(-900, 900).minutes
    rescue ArgumentError
      nil
    end
end
