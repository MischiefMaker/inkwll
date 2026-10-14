# How far an account has read an Inkling, for its unread marker.
class InklingRead < ApplicationRecord
  belongs_to :inkling
  belongs_to :account
end
