# New characters start as drafts when the game needs approval (the Character
# model sets that); everything else, including older characters, counts as
# approved.
class DefaultCharactersToApproved < ActiveRecord::Migration[8.1]
  def change
    change_column_default :characters, :status, from: "draft", to: "approved"
  end
end
