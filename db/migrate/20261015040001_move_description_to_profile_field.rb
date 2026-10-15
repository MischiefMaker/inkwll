# Character descriptions become an ordinary profile field, so games can
# rename it, make it a picture, or remove it. Existing descriptions are
# copied into it. The old column stays for now, untouched, as a safety copy.
class MoveDescriptionToProfileField < ActiveRecord::Migration[8.0]
  def up
    return unless select_value("SELECT EXISTS (SELECT 1 FROM characters WHERE description IS NOT NULL AND description <> '')") ||
      select_value("SELECT EXISTS (SELECT 1 FROM profile_fields)")

    field_id = select_value("SELECT id FROM profile_fields WHERE lower(name) = 'description' LIMIT 1")
    unless field_id
      required = select_value("SELECT require_description FROM game_settings LIMIT 1") || false
      position = (select_value("SELECT max(position) FROM profile_fields WHERE section = 'demographics'") || -1) + 1
      field_id = select_value(<<~SQL)
        INSERT INTO profile_fields (name, section, field_type, public, required, hint, position, created_at, updated_at)
        VALUES ('Description', 'demographics', 'long_text', true, #{required ? "true" : "false"}, 'How they look and come across.', #{position.to_i}, now(), now())
        RETURNING id
      SQL
    end

    execute <<~SQL
      INSERT INTO profile_values (character_id, profile_field_id, value, created_at, updated_at)
      SELECT id, #{field_id.to_i}, description, now(), now() FROM characters
      WHERE description IS NOT NULL AND description <> ''
      ON CONFLICT (character_id, profile_field_id) DO NOTHING
    SQL
  end

  def down
  end
end
