# Replaces the single admin switch with staff levels (Page, Scribe,
# Wellkeeper), the Founder flag, Page job flags and the Storyteller flag.
class AddStaffLevels < ActiveRecord::Migration[8.1]
  def up
    add_column :accounts, :staff_level, :integer, null: false, default: 0
    add_column :accounts, :founder, :boolean, null: false, default: false
    add_column :accounts, :storyteller, :boolean, null: false, default: false
    add_column :accounts, :job_flags, :string, array: true, null: false, default: []

    # Existing admins become Founders, so nobody loses access.
    execute "UPDATE accounts SET staff_level = 3, founder = TRUE WHERE admin = TRUE"
    remove_column :accounts, :admin
  end

  def down
    add_column :accounts, :admin, :boolean, null: false, default: false
    execute "UPDATE accounts SET admin = TRUE WHERE staff_level > 0"
    remove_column :accounts, :job_flags
    remove_column :accounts, :storyteller
    remove_column :accounts, :founder
    remove_column :accounts, :staff_level
  end
end
