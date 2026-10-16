# When a new Well's first Founder has signed up, its sign-up link is hidden
# on the Wells page. See docs/wells.md.
class AddFounderClaimedToWells < ActiveRecord::Migration[8.1]
  def change
    add_column :wells, :founder_claimed_at, :datetime
  end
end
