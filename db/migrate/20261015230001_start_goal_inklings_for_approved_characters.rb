# The owner asked for the Goals from approved characters' applications to
# become Goal Inklings on the next deploy. Newly approved characters already
# get one; this catches up the ones approved before. Safe to run twice.
class StartGoalInklingsForApprovedCharacters < ActiveRecord::Migration[8.1]
  def up
    [ ProfileField, Inkling ].each(&:reset_column_information)
    start! if Room.exists?
  end

  # Also points the Goals and Secrets fields at their Inkling types, so new
  # approvals start them too. Returns how many Inklings were made.
  def start!
    ProfileField.start_inklings_from_goals_and_secrets!
    field = ProfileField.where("lower(name) IN ('goal', 'goals')").where(field_type: %w[ text long_text ]).ordered.first or return 0
    return 0 unless ProfileField.inkling_kinds.key?(field.inkling_kind)
    made = 0
    Character.approved.played.includes(:account, :profile_values).find_each do |character|
      text = character.profile_value_for(field)&.value.presence or next
      next if character.account.nil? || Inkling.exists?(character: character, kind: field.inkling_kind, title: [ field.name, character.first_inkling_title(field) ])
      Inkling.start!(character: character, by: character.account, kind: field.inkling_kind, title: character.first_inkling_title(field), body: text, staff_visible: true)
      made += 1
    end
    made
  end

  def down
  end
end
