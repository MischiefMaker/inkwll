# A record that a player or a character was renamed, for staff to look back
# on. Made automatically (see LogsNameChanges) whoever does the renaming.
class NameChange < ApplicationRecord
  belongs_to :subject, polymorphic: true
  belongs_to :changed_by, class_name: "Account", optional: true

  scope :newest_first, -> { order(created_at: :desc, id: :desc) }

  def player? = subject_type == "Account"
end
