class AddAgeOnPassagesToProfileFields < ActiveRecord::Migration[8.1]
  def change
    add_column :profile_fields, :age_on_passages, :boolean, default: false, null: false
  end
end
