# Inklings: threads about a character that the player builds up and sends to
# staff. Players see their own characters' Inklings and those shared with
# them; staff find the rest under Admin, Inklings.
class InklingsController < ApplicationController
  include InklingsRequired
  limit_posting to: 10, within: 10.minutes, only: %i[ create update ]
  before_action :set_inkling, only: %i[ show update ]

  def index
    @show_closed = params[:closed] == "1"
    @inklings = Inkling.visible_to(current_account).where(status: @show_closed ? "closed" : "open")
      .includes(:character).newest_first
    @reads = InklingRead.where(account: current_account, inkling_id: @inklings.map(&:id)).pluck(:inkling_id, :last_read_sequence).to_h
  end

  def new
    @character = character_for_new
    @inkling = Inkling.new(character: @character)
  end

  def create
    @character = character_for_new
    @inkling = Inkling.start!(character: @character, by: current_account, kind: params.dig(:inkling, :kind).to_s,
      title: params.dig(:inkling, :title), body: params.dig(:inkling, :body))
    redirect_to @inkling, notice: "Started. Staff won't see it until you send it to them."
  rescue ActiveRecord::RecordInvalid, ArgumentError => e
    @inkling = Inkling.new(character: @character, kind: params.dig(:inkling, :kind), title: params.dig(:inkling, :title))
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_entity
  end

  def show
    @entries = @inkling.entries_visible_to(current_account)
    @last_read = @inkling.last_read_sequence_for(current_account)
    @inkling.mark_read!(current_account)
    Alert.read_for!(current_account, inkling: @inkling)
  end

  # The player renames it or changes its tags.
  def update
    return head :forbidden unless @inkling.owned_by?(current_account) || @inkling.staff_view?(current_account)
    tags = params.dig(:inkling, :tags).to_s.split(",").map { |tag| tag.squish.downcase.first(30) }.compact_blank.uniq.first(10)
    if @inkling.update(title: params.dig(:inkling, :title).presence || @inkling.title, tags: tags)
      redirect_to @inkling, notice: "Saved."
    else
      redirect_to @inkling, alert: @inkling.errors.full_messages.to_sentence
    end
  end

  private
    def set_inkling
      @inkling = Inkling.find(params[:id])
      raise ActiveRecord::RecordNotFound unless @inkling.visible_to?(current_account)
    end

    # Players start Inklings for their own approved characters; staff can
    # start one for any approved character.
    def character_for_new
      id = params[:character_id] || params.dig(:inkling, :character_id) || current_character&.id
      scope = current_account.can?(:review_apps) ? Character.active : current_account.characters.active
      scope.where(status: "approved").find(id)
    end
end
