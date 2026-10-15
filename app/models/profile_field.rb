# A field on character profiles, set up by each game: in Demographics (shown
# at the top of the profile) or the Application tab. Public fields show to
# everyone; private ones only to the character's player and staff.
class ProfileField < ApplicationRecord
  SECTIONS = %w[ demographics application ].freeze
  # birthday is a date that also shows the character's age.
  FIELD_TYPES = { "text" => "Short text", "long_text" => "Long text", "birthday" => "Birthday (shows age)", "date" => "Date", "number" => "Number", "image" => "Picture" }.freeze

  has_many :profile_values, dependent: :delete_all

  validates :name, presence: true, length: { maximum: 60 }
  validates :section, inclusion: { in: SECTIONS }
  validates :field_type, inclusion: { in: FIELD_TYPES.keys }
  validates :hint, length: { maximum: 300 }
  validate :pictures_stay_on_the_profile
  validate :inkling_kind_is_a_type_players_start

  scope :ordered, -> { order(:position, :id) }
  scope :in_section, ->(section) { where(section: section).ordered }

  def date?
    field_type.in?(%w[ birthday date ])
  end

  # A picture answer, for games that show looks with an image instead of text.
  def image?
    field_type == "image"
  end

  # Whether this answer is locked for a player once their character is approved.
  def locked_for?(character, editor)
    !player_can_edit? && character.approved? && !editor&.staff?
  end

  # Whether an approved character's answer starts an Inkling.
  def starts_inkling? = inkling_kind.present?

  # The Inkling types a field can start: ones players start themselves.
  def self.inkling_kinds
    Inkling.types.reject { |_, type| type["category"] == "staff" }.transform_values { |type| type["name"] }
  end

  private
    def inkling_kind_is_a_type_players_start
      return if inkling_kind.blank?
      errors.add(:inkling_kind, "isn't a type players can start") unless self.class.inkling_kinds.key?(inkling_kind)
      errors.add(:inkling_kind, "can't be used with a picture, date or number") unless field_type.in?(%w[ text long_text ])
    end

    # A picture can't sit in the short line beside Passages, or be asked
    # in a roster application.
    def pictures_stay_on_the_profile
      return unless image?
      errors.add(:on_passages, "can't be used with a picture") if on_passages?
      errors.add(:ask_on_roster, "can't be used with a picture") if ask_on_roster?
    end
end
