# A player's login. Characters belong to an account and have no login of their own.
class Account < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :characters, dependent: :destroy
  has_many :remembered_characters, dependent: :delete_all
  has_many :ooc_messages, dependent: :destroy
  belongs_to :active_character, class_name: "Character", optional: true

  normalizes :username, with: ->(u) { u.strip.downcase }
  normalizes :display_name, with: ->(n) { n.strip }

  validates :username, presence: true, uniqueness: true, length: { maximum: 30 },
    format: { with: /\A[a-z0-9_]+\z/, message: "can only use letters, numbers and underscores" }
  validates :display_name, presence: true, length: { maximum: 40 }
  validate :active_character_must_be_own

  # Makes the given character active and remembers it for the room it is in.
  def switch_to(character)
    update!(active_character: character)
    remember_character(character, character.room)
  end

  # Remembers that this character was last used in the given place (a room or scene).
  def remember_character(character, context)
    remembered_characters.find_or_initialize_by(context: context).update!(character: character)
  end

  def remembered_character_for(context)
    remembered_characters.find_by(context: context)&.character
  end

  private
    def active_character_must_be_own
      if active_character && active_character.account_id != id
        errors.add(:active_character, "must be one of your own characters")
      end
    end
end
