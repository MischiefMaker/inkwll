# Passages meant for some characters only.
#
# - mutter: whispered to one character in the Chapter. Its players see the
#   whole thing; everyone else sees the overheard version, where most of the
#   words are lost as "...". It doesn't take a turn.
# - aside: from the Storyteller to one character. Nobody else sees it at all.
module Pose::Whispers
  extend ActiveSupport::Concern

  # Roughly one word in three is overheard.
  OVERHEARD_SHARE = 1 / 3r

  included do
    before_save :overhear, if: -> { mutter? && (body_changed? || overheard_body.nil?) }
    validate :mutter_needs_someone_to_hear_it, if: -> { mutter? || aside? }
  end

  def to_characters = Character.where(id: to_character_ids)

  # Whether the Passage shows at all for this account: asides only to the
  # two people they're between.
  def shown_to?(account) = !aside? || full_for?(account)

  # Whether this account sees the whole Passage: its writer, and the players
  # of the characters it was meant for.
  def full_for?(account)
    return true unless mutter? || aside?
    return false unless account
    ids = account.characters.pluck(:id)
    ids.include?(character_id) || to_character_ids.intersect?(ids)
  end

  # The text this account sees.
  def body_for(account)
    return body if full_for?(account)
    aside? ? "" : overheard_body.to_s
  end

  # Keeps about a third of the words, chosen at random, and turns each run of
  # lost words into "...". Never keeps every word.
  def self.overheard(text, random: Random.new)
    words = text.to_s.split
    return "..." if words.size < 3
    keep = words.each_index.to_a.sample([ (words.size * OVERHEARD_SHARE).floor, 1 ].max, random: random).to_set
    words.each_index.chunk_while { |a, b| keep.include?(a) == keep.include?(b) }.map do |run|
      keep.include?(run.first) ? run.map { |i| words[i] }.join(" ") : "..."
    end.join(" ")
  end

  private
    def overhear
      self.overheard_body = Pose::Whispers.overheard(body)
    end

    def mutter_needs_someone_to_hear_it
      others = scene.participants.where.not(character_id: character_id).pluck(:character_id)
      errors.add(:base, "Choose who it's for.") if to_character_ids.size != 1 || !others.include?(to_character_ids.first)
    end
end
