# Version 2.0: scene prompts. Staff write short ideas for Chapters, and the
# "Give me an idea" button on the new Chapter form fills one in at random.
class CreateSceneIdeas < ActiveRecord::Migration[8.1]
  def change
    create_table :scene_ideas do |t|
      t.string :title, null: false
      t.string :subtitle
      t.timestamps
    end
  end
end
