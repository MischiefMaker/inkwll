class SimplifyRoomKinds < ActiveRecord::Migration[8.1]
  # Hotels, dormitories and office blocks become buildings with separate units.
  def up
    execute "UPDATE rooms SET kind = 'apartments' WHERE kind IN ('hotel', 'dorms', 'offices')"
  end

  def down
  end
end
