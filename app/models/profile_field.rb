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
  validate :age_needs_a_birthday
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
  # For games set up before Goals and Secrets started Inklings: points those
  # two fields at their Inkling types if nobody has chosen one, so approving a
  # character turns the answers into Inklings. Leaves any choice already made.
  def self.start_inklings_from_goals_and_secrets!
    { "goal" => "goal", "goals" => "goal", "secret" => "secret", "secrets" => "secret" }.each do |name, kind|
      where("lower(name) = ?", name).where(field_type: %w[ text long_text ], inkling_kind: [ nil, "" ]).find_each do |field|
        field.update!(inkling_kind: kind) if inkling_kinds.key?(kind)
      end
    end
  end

  def self.inkling_kinds
    Inkling.types.reject { |_, type| type["category"] == "staff" }.transform_values { |type| type["name"] }
  end

  private
    def age_needs_a_birthday
      errors.add(:age_on_passages, "can only be used with a Birthday field") if age_on_passages? && field_type != "birthday"
    end

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
