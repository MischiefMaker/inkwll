# A ready-made idea for a Chapter, written by staff. "Give me an idea" on the
# new Chapter form copies a random one into the title and subtitle, where the
# player can change it before starting.
class SceneIdea < ApplicationRecord
  normalizes :title, with: ->(t) { t.squish }
  normalizes :subtitle, with: ->(s) { s.squish.presence }
  validates :title, presence: true, length: { maximum: 100 }
  validates :subtitle, length: { maximum: 150 }

  # What the new Chapter form needs, a few hundred at most.
  def self.for_form
    order(:id).limit(500).map { |idea| { title: idea.title, subtitle: idea.subtitle.to_s } }
  end
end
