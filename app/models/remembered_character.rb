# Which character an account last used in a given place (a room, and later a scene).
class RememberedCharacter < ApplicationRecord
  belongs_to :account
  belongs_to :character
  belongs_to :context, polymorphic: true
end
