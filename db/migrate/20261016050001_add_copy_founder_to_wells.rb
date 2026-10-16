# A new Well can open its first sign-up link with the starting Founder's name
# and email already filled in. See docs/wells.md.
class AddCopyFounderToWells < ActiveRecord::Migration[8.1]
  def change
    add_column :wells, :copy_founder, :boolean, null: false, default: false
  end
end
