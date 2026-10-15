# The owner wants Inklings made from an application answer to be called
# "Lucia's First Goal" / "Lucia's First Secret", not just "Goals" / "Secrets".
# Renames the ones already made. Safe to run twice.
class RenameApplicationInklings < ActiveRecord::Migration[8.1]
  def up
    [ ProfileField, Inkling ].each(&:reset_column_information)
    Character.rename_application_inklings!
  end

  def down
  end
end
