# A profile field can start an Inkling when its character is approved, so a
# Goals answer becomes a Goal Inkling and a Secrets answer a Secret one
# (owner). Existing games get the starter Goals and Secrets fields wired up.
class AddInklingKindToProfileFields < ActiveRecord::Migration[8.1]
  def up
    add_column :profile_fields, :inkling_kind, :string
    ProfileField.reset_column_information
    goals = ProfileField.find_by(name: "Goals", inkling_kind: nil)
    goals&.update_columns(inkling_kind: "goal")
    if goals && !ProfileField.exists?(name: "Secrets")
      ProfileField.create!(name: "Secrets", section: "application", field_type: "long_text", public: false, required: false,
        hint: "Something your character is hiding. Only you and staff can see this.", inkling_kind: "secret", position: ProfileField.maximum(:position).to_i + 1)
    end
  end

  def down
    remove_column :profile_fields, :inkling_kind
  end
end
