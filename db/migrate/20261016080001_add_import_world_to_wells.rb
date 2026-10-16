# A Well started with "I'll import a world pack" sends its Founder straight to
# Import a world after signing up. See docs/wells.md.
class AddImportWorldToWells < ActiveRecord::Migration[8.1]
  def change
    add_column :wells, :import_world, :boolean, default: false, null: false
  end
end
