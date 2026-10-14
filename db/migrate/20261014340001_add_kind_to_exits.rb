# Path types (owner, 2026-10-14): streets (can point a compass direction),
# buildings (things to go into) and units (apartments and the like).
class AddKindToExits < ActiveRecord::Migration[8.1]
  def change
    add_column :exits, :kind, :string, default: "street", null: false
    # Paths with a door number are units.
    up_only { execute "UPDATE exits SET kind = 'unit' WHERE number IS NOT NULL" }
  end
end
