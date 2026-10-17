# "The story so far": a short summary any player in a Chapter can keep up to
# date, so someone joining a long Chapter can catch up without reading every
# Passage. Lists show it cut to one line.
module Scene::StorySoFar
  extend ActiveSupport::Concern

  SUMMARY_LENGTH = 1_500
  LINE_LENGTH = 150

  included do
    belongs_to :summary_by, class_name: "Character", optional: true
    normalizes :summary, with: ->(text) { text.strip.presence }
    validates :summary, length: { maximum: SUMMARY_LENGTH }
  end

  def update_summary!(text, by:)
    update!(summary: text, summary_by: by, summary_at: Time.current)
  end

  def summary_line
    summary&.squish&.truncate(LINE_LENGTH, separator: " ")
  end
end
