# An Inkling shared with one character, whose player can then read it and
# write in it.
class InklingShare < ApplicationRecord
  belongs_to :inkling
  belongs_to :character
  validates :character_id, uniqueness: { scope: :inkling_id }
end
