# Inklings made from an application's Goals and Secrets weren't showing in the
# admin Inklings list, because staff only see Inklings a player sent them.
# Staff already read the application, so these are shown to staff. Safe to run twice.
class ShowApplicationInklingsToStaff < ActiveRecord::Migration[8.1]
  def up
    [ ProfileField, Inkling ].each(&:reset_column_information)
    show!
  end

  # Returns how many were shown.
  def show!
    shown = 0
    ProfileField.where.not(inkling_kind: [ nil, "" ]).find_each do |field|
      Inkling.where(kind: field.inkling_kind, staff_visible_at: nil).includes(:character).find_each do |inkling|
        next unless inkling.title == inkling.character.first_inkling_title(field)
        inkling.update_columns(staff_visible_at: Time.current)
        shown += 1
      end
    end
    shown
  end

  def down
  end
end
