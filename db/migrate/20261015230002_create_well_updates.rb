# One row each time the Founder presses Update on the Wells page, so the page
# can show how the update is going and who started it.
class CreateWellUpdates < ActiveRecord::Migration[8.1]
  def change
    create_table :well_updates do |t|
      t.references :account, null: false, foreign_key: true
      t.string :version, null: false
      t.string :request_id, null: false
      t.string :status, null: false, default: "requested"
      t.string :conclusion
      t.bigint :run_id
      t.string :run_url
      t.timestamps
    end
  end
end
