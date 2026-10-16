# Inklings made from an application's Goals and Secrets weren't showing in the
# admin Inklings list, because staff only see Inklings a player sent them.
# Staff already read the application, so these are shown to staff. Safe to run twice.
class ShowApplicationInklingsToStaff < ActiveRecord::Migration[8.1]
  def up
    [ ProfileField, Inkling ].each(&:reset_column_information)
    Character.show_application_inklings_to_staff!
  end

  def down
  end
end
