# The event calendar: events at a Place and time that characters sign up for.
# When one starts, a Chapter opens for it.
class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.text :description
      t.references :room, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :starts_at, null: false
      t.references :host, foreign_key: { to_table: :characters, on_delete: :nullify }
      t.references :created_by, foreign_key: { to_table: :accounts, on_delete: :nullify }
      t.references :scene, foreign_key: { on_delete: :nullify }
      t.datetime :opened_at
      t.datetime :cancelled_at
      t.timestamps
    end
    add_index :events, :starts_at

    create_table :event_signups do |t|
      t.references :event, null: false, foreign_key: { on_delete: :cascade }
      t.references :character, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end
    add_index :event_signups, %i[ event_id character_id ], unique: true

    add_reference :alerts, :event, foreign_key: { on_delete: :cascade }
  end
end
