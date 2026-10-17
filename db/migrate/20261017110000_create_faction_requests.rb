# An approved character asking to join an open faction. Its heads and staff
# accept or decline it on the faction's page.
class CreateFactionRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :faction_requests do |t|
      t.references :faction, null: false, foreign_key: { on_delete: :cascade }
      t.references :character, null: false, foreign_key: { on_delete: :cascade }
      t.string :note
      t.string :status, null: false, default: "pending"
      t.references :decided_by, foreign_key: { to_table: :accounts, on_delete: :nullify }
      t.datetime :decided_at
      t.timestamps
      t.index %i[ faction_id character_id ], unique: true, where: "status = 'pending'", name: "index_faction_requests_one_pending"
    end

    add_reference :alerts, :faction, foreign_key: { on_delete: :cascade }
  end
end
