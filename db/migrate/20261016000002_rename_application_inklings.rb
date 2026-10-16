# The owner wants Inklings made from an application answer to be called
# "Lucia's First Goal" / "Lucia's First Secret", not just "Goals" / "Secrets".
# Renames the ones already made. Safe to run twice.
class RenameApplicationInklings < ActiveRecord::Migration[8.1]
  def up
    [ ProfileField, Inkling ].each(&:reset_column_information)
    rename!
  end

  # Returns how many were renamed.
  def rename!
    renamed = 0
    ProfileField.where.not(inkling_kind: [ nil, "" ]).find_each do |field|
      Inkling.where(kind: field.inkling_kind, title: field.name).includes(:character).find_each do |inkling|
        inkling.update_columns(title: inkling.character.first_inkling_title(field))
        renamed += 1
      end
    end
    renamed
  end

  def down
  end
end
