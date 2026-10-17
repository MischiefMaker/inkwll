# Version 2.0: in-character letters and texts, a kind of Passage shown as a
# letter on paper or as a message on a phone, addressed to someone.
class AddLettersToPoses < ActiveRecord::Migration[8.1]
  def change
    add_column :poses, :letter_style, :string
    add_column :poses, :letter_to, :string
  end
end
