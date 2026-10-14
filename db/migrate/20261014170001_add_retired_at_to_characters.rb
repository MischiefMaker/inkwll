# Characters are never deleted, only retired. Retired characters can't be
# played, but their Passages and Manuscripts still show them.
class AddRetiredAtToCharacters < ActiveRecord::Migration[8.1]
  def change
    add_column :characters, :retired_at, :datetime
  end
end
