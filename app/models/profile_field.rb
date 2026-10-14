# A field on character profiles, set up by each game: in Demographics (shown
# at the top of the profile) or the Application tab. Public fields show to
# everyone; private ones only to the character's player and staff.
class ProfileField < ApplicationRecord
  SECTIONS = %w[ demographics application ].freeze
  # birthday is a date that also shows the character's age.
  FIELD_TYPES = { "text" => "Short text", "long_text" => "Long text", "birthday" => "Birthday (shows age)", "date" => "Date", "number" => "Number" }.freeze

  has_many :profile_values, dependent: :delete_all

  validates :name, presence: true, length: { maximum: 60 }
  validates :section, inclusion: { in: SECTIONS }
  validates :field_type, inclusion: { in: FIELD_TYPES.keys }
  validates :hint, length: { maximum: 300 }

  scope :ordered, -> { order(:position, :id) }
  scope :in_section, ->(section) { where(section: section).ordered }

  def date?
    field_type.in?(%w[ birthday date ])
  end
end
